.PHONY: pg-up
pg-up:
	docker-compose up -d

down:
	docker-compose down

clean:
	rm -rf ./pgdata