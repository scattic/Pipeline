import time
from datetime import datetime
from elasticsearch import Elasticsearch


START = time.time()

ES = Elasticsearch([{'host': 'elasticsearch-master', 'port': 9200}])

DOC = {
    'reason': 'testing',
    'type': 'performance',
    'timestamp': datetime.now(),
}

print("> creating index & 100 documents")

for i in range(100):
    RES = ES.index(index="test-index", id=1, body=DOC)
    print(RES)

    print("> check document was created")
    RES = ES.get(index="test-index", id=1)
    print(RES)

print("> prepare data for search")
ES.indices.refresh(index="test-index")

print("> testing query")
RES = ES.search(index="test-index", body={"query": {"match_all": {}}})
print(">> got %d Hits:" % RES['hits']['total']['value'])
for hit in RES['hits']['hits']:
    print(">> %(timestamp)s %(reason)s: %(type)s" % hit["_source"])

print("> deleting index")
RES = ES.indices.delete(index='test-index', ignore=[400, 404])
print(RES)

END = time.time()
print("> execution completed, run time was: ")
if (END - START)<10:
  print("TEST-SUCCESS")
else:
  print("TEST-FAILED")
