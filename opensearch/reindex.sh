# 
# Proof of concept script to better understand how the reindex process works
# 
# TODO:
#   - track state of each index migration
#       - old (no acitons taken yet)
#       - active write index y/n, rotated active write index
#       - temp new index created
#       - first reindex started/inprogress to tmp index
#       - first reindex completed
#       - orig index deleted
#       - orig index recreated
#       - second reindex started/inprogress from tmp to orig index
#       - second reindex compelted
#       - document counts verified/reconciled
#       - index range rebuilt
#       - temp index deleted
# 

get_old_indices() {
    # returns a list of indices that are old and need to be reindexed

    local OLD_INDICES=$(http :9200/_settings | jq '[ path(.[] | select( (.settings.index.version.created|tonumber) < 135247827 ))[] ]' | jq -r '.[]')
    echo "$OLD_INDICES"
}

get_active_write_indices() {
    # returns a list of active write indices

    local ACTIVE_WRITE_INDICES=$(http ':9200/*_deflector/_alias' | jq 'keys' | jq -r '.[]')
    echo "$ACTIVE_WRITE_INDICES"
}

is_in_list() {
    # returns 1 if needle is contained in a haystack
    # haystack expects a list with 1 entry per line

    # echo ""
    # echo ""
    local needle="$1"
    local haystack="$2"
    
    while IFS= read -r line; do
        if [[ "$line" == "$needle" ]]; then
            # echo "$line contained in list"
            echo 1
        fi
    done <<< "$haystack"
}

return_item_from_list() {
    # returns line of list that needle is contained in
    # haystack expects a list with 1 entry per line

    # echo ""
    # echo ""
    local needle="$1"
    local haystack="$2"
    local splitchar="$3"
    local findpos="$4"
    local returnpos="$5"

    # IN="bla@some.com;john@home.com"
    # arrIN=(${IN//;/ })
    # echo ${arrIN[1]}                  # Output: john@home.com
    
    while IFS= read -r line; do
        arrIN=(${line//$splitchar/ })
        # echo ${arrIN[0]}
        # echo ${arrIN[1]}
        if [[ "${arrIN[$findpos]}" == "$needle" ]]; then
            echo "${arrIN[$returnpos]}"
        fi
    done <<< "$haystack"
}

get_old_active_write_indices() {
    # returns a list of old indices that need to be reindexed, that are also active write indices
    #   these will all need to be rotated

    # rm -f tmp_out_old_active_write_indices
    while IFS= read -r line; do
        # is_in_list $line "$OLD_INDICES"
        if [ "$(is_in_list $line "$OLD_INDICES")" == "1" ]; then
            echo $line
            # echo $line >> tmp_out_old_active_write_indices
        fi
    done <<< $(get_active_write_indices)
}

# get list of index sets

get_list_of_index_sets() {
    # returns a list of all index sets
    # local CURLOUTPUT=$(curl --silent --user ${GRAYLOG_API_TOKEN}:token "${GRAYLOG_API_URL}system/indices/index_sets?skip=0&limit=0&stats=false")

    local LIST_OF_INDEX_SETS=$(http --auth ${GRAYLOG_API_TOKEN}:token "${GRAYLOG_API_URL}system/indices/index_sets?skip=0&limit=0&stats=false" | jq '.index_sets[].id' | jq '' -r)
    echo "$LIST_OF_INDEX_SETS"
}

get_list_of_indices_from_index_set() {
    local INDEX_SET_ID="$1"
    # echo $INDEX_SET_ID
    # /api/system/indexer/indices/662a6bcbf01ce23a39d06924/list
    # local LIST_OF_INDICES=$(http --auth ${GRAYLOG_API_TOKEN}:token "${GRAYLOG_API_URL}system/indexer/indices/${INDEX_SET_ID}/list" | jq '')
    local LIST_OF_INDICES=$(curl --silent --user ${GRAYLOG_API_TOKEN}:token "${GRAYLOG_API_URL}system/indexer/indices/${INDEX_SET_ID}/list" | jq '.all.indices | keys[]' | jq '' -r)
    #  | jq '.all.indices | keys[]' | jq '' -r
    echo "$LIST_OF_INDICES"
}

get_list_of_index_set_indices() {
    # returns a list of inddices for a given index set
    local LIST_OF_INDEX_SET_INDICES=""

    # get_list_of_index_sets
    tmp_get_list_of_index_sets=$(get_list_of_index_sets)

    # iterate, get list of incides for each index set
    while IFS= read -r index_set_id; do
        # echo "${index_set_id}..."
        tmp_get_list_of_indices_from_index_set=$(get_list_of_indices_from_index_set "${index_set_id}")
        while IFS= read -r index_in_indexset; do
            if [ -z "${index_in_indexset}" ]; then
                # empty
                a=1
            else
                # echo "${index_set_id};${index_in_indexset}"
                LIST_OF_INDEX_SET_INDICES+="${index_set_id};${index_in_indexset}"$'\n'
            fi
        done <<< "$tmp_get_list_of_indices_from_index_set"
    done <<< "$tmp_get_list_of_index_sets"

    a=1
    echo "$LIST_OF_INDEX_SET_INDICES"
}

rotate_index_set_by_idnex_set_id() {
    local INDEX_SET_ID="$1"

    curl \
        -X POST \
        -H "Content-Type: application/json" \
        -H "X-Requested-By: curl" \
        --user ${GRAYLOG_API_TOKEN}:token \
        -v \
        "${GRAYLOG_API_URL}cluster/deflector/${INDEX_SET_ID}/cycle"
}

rotate_old_active_write_indices() {
    local LIST_OF_INDEX_SET_INDICES=$(get_list_of_index_set_indices)

    while IFS= read -r line; do
        if [ -z "${line}" ]; then
            a=1
        else
            local INDEX_SET_ID_TO_ROTATE=$(return_item_from_list $line "$LIST_OF_INDEX_SET_INDICES" ";" "1" "0")
            echo "Index set id to rotate: ${INDEX_SET_ID_TO_ROTATE}"
            # we need to translate the index name to its indexsetid
            rotate_index_set_by_idnex_set_id ${INDEX_SET_ID_TO_ROTATE}
        fi
    done <<< $(get_old_active_write_indices)
}

TMP_REINDEX_SUFFIX=_reindex

# Safety Checks
if [ -z "${GRAYLOG_API_URL}" ]; then
    echo "ERROR! Please specify Graylog API URL using envvar GRAYLOG_API_URL"
    echo "Please end the url with a trailing slash: \"/\""
    echo "export GRAYLOG_API_URL=http://127.0.0.1:9000/api/"
    exit 1
fi
if [[ "$GRAYLOG_API_URL" =~ ^http[s]?://.*/api/$ ]]; then
    a=1
else
    echo "ERROR! Invalid Graylog API URL"
    echo "Must be in one of the following formats:"
    echo "http://hostname.domain.tld/api/"
    echo "http://hostname.domain.tld:9000/api/"
    echo "https://hostname.domain.tld/api/"
    exit 1
fi

if [ -z "${GRAYLOG_API_TOKEN}" ]; then
    echo "ERROR! Please specify Graylog API Token using envvar GRAYLOG_API_TOKEN"
    echo "export GRAYLOG_API_TOKEN="
    exit 1
fi

echo "Graylog API Url: ${GRAYLOG_API_URL}"
echo "Temporary reindex index suffix '${TMP_REINDEX_SUFFIX}'"

# Do The Work

OLD_INDICES=$(get_old_indices)
echo ""
echo "Indices found with old index versions:"
echo "$OLD_INDICES"

echo ""
echo "Old indices that are still active write indices. These need to be rotated"
get_old_active_write_indices

echo ""
echo "Attempting to rotate Old Active Write indices..."
rotate_old_active_write_indices

# https://go2docs.graylog.org/5-2/upgrading_graylog/elasticsearch_reindexing_notes.html

# Create New Index
# 
# http put :9200/graylog_0_reindex settings:='{"number_of_shards":4,"number# we need to get the current shard and replica count and set those values (optionally specify as envvar?)_of_replicas":0}'

# Check Mapping and Index Settings
# Use these commands to check if the settings and index mapping for the new index are correct:
# 
# http :9200/graylog_0_reindex/_mapping
# http :9200/graylog_0_reindex/_settings

# Start reindex
# 
# http post :9200/_reindex wait_for_completion==false source:='{"index":"graylog_0","size": 1000}' dest:='{"index":"graylog_0_reindex"}'
# OR
# http post :9200/_reindex wait_for_completion==false requests_per_second==500 source:='{"index":"graylog_0","size": 1000}' dest:='{"index":"graylog_0_reindex"}'
# ... does not wait for return, returns async

# Check status?
# 
# http :9200/_tasks/

# Compare Document Counts
# 
# http :9200/graylog_0/_count
# http :9200/graylog_0_reindex/_count

# Delete existing, now old, index
# 
# http delete :9200/graylog_0

# Recreate Old Index
# we need to get the current shard and replica count and set those values (optionally specify as envvar?)
# 
# http put :9200/graylog_0 settings:='{"number_of_shards":4,"number_of_replicas":0}'

# check mappings?
# 
# http :9200/graylog_0/_mapping
# http :9200/graylog_0/_settings

# Start reindex Process for Old Index
# 
# http post :9200/_reindex wait_for_completion==false source:='{"index":"graylog_0_reindex","size": 1000}' dest:='{"index":"graylog_0"}'
# OR
# http post :9200/_reindex wait_for_completion==false requests_per_second==500 source:='{"index":"graylog_0_reindex","size": 1000}' dest:='{"index":"graylog_0"}'

# Comapre doc count from old/new index
# 
# http :9200/graylog_0/_count
# http :9200/graylog_0_reindex/_count

# Rebuild index range
# 
# http post :9000/api/system/indices/ranges/graylog_0/rebuild x-requested-by:httpie

# Delete Temp index
# 
# http delete :9200/graylog_0_reindex

# Cleanup
# remove completed tasks (is this required???)
# 
# http :9200/.tasks/_search | jq '[.hits.hits[] | select(._source.task.action == "indices:data/write/reindex" and ._source.completed == true) | {"task_id": ._id, "description": ._source.task.description}]'
# http delete :9200/.tasks/task/PUT_YOUR_TASK_ID_HERE
