
all: resign

resign: resign.c
	cc -I/usr/local/Cellar/openssl\@1.1/1.1.1l/include/ -L/usr/local/Cellar/openssl\@1.1/1.1.1l/lib/ -o resign resign.c -lcrypto 

test:	resign
	@openssl req -new -x509 -subj /CN=foo -set_serial 1 -nodes -keyout /dev/stdout > cert1.pem 2> /dev/null
	@openssl req -new -x509 -subj /CN=bar -set_serial 1 -nodes -keyout /dev/stdout > cert2.pem 2> /dev/null
	@echo
	@echo Current issuer/subject
	@openssl x509 -noout -issuer -subject -in cert1.pem
	@echo
	@echo Replacing self-sig signature of foo on foo by bar
	./resign -v cert1.pem cert2.pem > cert3.pem
	@echo
	@echo Resign issuer/subject
	@echo
	@openssl x509 -noout -issuer -subject -in cert3.pem

clean:
	rm -f resign.o cert1.pem cert2.pem cert3.pem
