FROM python:3.6

RUN mkdir /elastalert
WORKDIR /elastalert

#install flask python requirement
COPY ./requirements.txt ./requirements.txt
RUN pip install -r ./requirements.txt

COPY ./elastalert/ /elastalert

RUN rm /entrypoint.sh || exit 0
# Copy the entrypoint that will generate Nginx additional configs
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
