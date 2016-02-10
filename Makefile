
connect-test-app:
	(cd testApp && \
		steroids connect \
			--watch=../src \
			--no-qrcode \
			--simulate)

connect-test-spec-app:
	(cd testSpecApp && \
		steroids connect \
			--watch=../src \
			--no-qrcode \
			--simulate)
