FROM frappe/bench:latest

WORKDIR /workspace

COPY docker/init.sh /workspace/init.sh

EXPOSE 8000

CMD ["bash", "/workspace/init.sh"]
