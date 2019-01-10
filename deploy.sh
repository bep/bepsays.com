rm -rf public
hugo
s3deploy -source=public/ -region=eu-west-1 -bucket=bepsays.com -public-access -distribution-id=E18C62T0HLIL27