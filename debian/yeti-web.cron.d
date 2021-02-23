MAILTO=""
10 * * * *   yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/CdrPartitioning/run
*/30 * * * * yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/CdrBatchCleaner/run
20 * * * *   yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/PartitionRemoving/run
* * * * *    yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/EventProcessor/run
* * * * *    yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/CallsMonitoring/run
35 * * * *   yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/StatsClean/run
25 * * * *   yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/StatsAggregation/run
30 5 * * *   yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/Invoice/run
*/15 * * * * yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/ReportScheduler/run
*/16 * * * * yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/TerminationQualityCheck/run
* * * * *    yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/DialpeerRatesApply/run
* * * * *    yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/AccountBalanceNotify/run
0 2 * * *    yeti-web curl -X PUT -H 'Content-Length: 0' http://127.0.0.1:6666/api/rest/system/jobs/SyncDatabaseTables/run
