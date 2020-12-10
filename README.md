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
            
## (Windows) 部署 filebeat 與 winlogbeat
## (Linux) 部署 filebeat