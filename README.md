# EFK-Filebeat-Stack
此Repo是個簡單的 log monitor 架構，由 Filebeat 蒐集並傳送 log 到 fluentd 進行過濾後儲存於 elasticsearch。最後在 kibana 呈現 log。

這個 stack 同時包含了用來定期清理 log 的 curator 以及用來監控並發送警訊的 elastalert。

# 環境準備
1. docker
2. docker-compose

# 部署
## 部署 EFK Stack
1. 將 EFK 這個目錄放到具有 docker 環境的機器上。
2. 調整 config:
    * fluentd (EFK/docker/fluentd/fluent.conf):
        * [Configuration - Fluentd](https://docs.fluentd.org/configuration)
        * [Fluentular: a Fluentd regular expression editor](http://fluentular.herokuapp.com/)
        * 此 config 主要需要設定 filter 的名稱以及 log 的 regular expression，此部分使用 tag 來區分不同種類的 log，tag需要在 filebeat 的 filebeat.yml中設定。
    * curator (EFK/docker/fluentd/curator/action_file) : 
        * [Configuration | Curator Reference [5.7] | Elastic](https://www.elastic.co/guide/en/elasticsearch/client/curator/5.7/configuration.html)
        * 設定保留log的時間 (EFK/docker/fluentd/curator/action_file):
            * unit: 時間單位
            * unit_count: 時間長度
3. 在 docker 路徑下( /...where_you_deploy.../EFK/docker)以docker-compose up啟動服務，若不想要直接輸出log，可以加上 -d 
```
docker-compose up
# or
docker-compose up -d
```
4. 透過 docker ps 指令，確認所有服務皆有啟動。若為 elasticsearch 無法順利啟動，有可能是 mount 的路徑有權限問題，請設定好權限之重新操作。
```
docker ps
```

## (Windows) 部署 filebeat 與 winlogbeat
(TBD)
## (Linux) 部署 filebeat
1. 將 Filbeat/linux 這個目錄放到具有 docker 環境的機器上。
2. 調整 config:
    * docker-compose.yml:
        * 將要蒐集的 log 路徑 mount 進 container
        * 主要設定 "volumes:" 這個欄位，以 - < actual_log_path_in_linux_host >:< log_path_in_container_and_set_in_filebeat_yaml > 這個格式設定，若有多個路徑可以設定多個。
    * Filebeat.yml:
        * [filebeat.reference.yml | Filebeat Reference [7.8] | Elastic](https://www.elastic.co/guide/en/beats/filebeat/7.8/filebeat-reference-yml.html)
        * log路徑： 設定你要新增的 log 路徑，需要特別注意這邊設定的是container內的路徑，也就是剛剛在docker-compose.yml 內設定的< log_path_in_container_and_set_in_filebeat_yaml >
        * tag: 設定fields.tag，此 tag 的值需要與 fluntd 的 config (fluent.conf) 內 filter 所設定的值相同，才能讓 fluent 能去爬取這個 log 的欄位
        * 多行log的設定： 設定 multiline.pattern ，此值用來代表 log 的開頭應該長什麼樣子，這個值通常是 log 的 timestamp 格式，需要以 regular expression 表示。
        * 設定 fluentd 的位置: Filebeat 需要將 log 送往 fluentd。設定 output.logstash.hosts 的值來代表要送往的 fluentd 位置。需要特別注意以下兩點
            * 不可以使用 localhost 與 127.0.0.1，原因是這個值是給 docker container 看的，從 container 內無法直接用 localhost 與主機溝通
            * 5044 port 是 fluentd 用來接收 filebeat 傳送的 log，若設定為 9200 則為直接送到 elasticsearch ，就無法被 fluent 爬取 log 資訊。 
3. 在 docker 路徑下( /...where_you_deploy.../Filebeat/linux/docker)以docker-compose up啟動服務。
```
docker-compose up
```