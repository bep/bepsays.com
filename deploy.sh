rm -rf public
hugo
s3deploy -source=public/ -region=eu-west-1 -bucket=bepsays.com -distribution-id=E18C62T0HLIL27