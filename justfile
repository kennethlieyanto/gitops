docker-service-dir := "docker-services"

list:
    ls {{ docker-service-dir }}

start service:
    cd {{ docker-service-dir }}/{{ service }} && docker compose up -d

stop service:
    cd {{ docker-service-dir }}/{{ service }} && docker compose down 
