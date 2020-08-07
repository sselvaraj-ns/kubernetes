# Step1: Creating a seprate directory for mainting all certificates.
mkdir $HOME/cert

# Step2: Create local server as a CA server for generating users certification.
# Use OPENSSL tool to generate the private key.
openssl genrsa -out $HOME/cert/ca.key 2048

# Step3: Generate the Certificate signing request.
openssl req -new -key $HOME/cert/ca.key -subj "/CN=KUBERNETES-CA" -out $HOME/cert/ca.csr

# IMP ##Root Public Certificate should be available in all k8s components
# Step3: Sign the csr requested certificate and provide a publick key along with certificate
openssl x509 -req -days 100 -in $HOME/cert/ca.csr -signkey $HOME/cert/ca.key -out $HOME/cert/ca.crt

#Step4: We got the two main files. CA private key (ca.key) and CA public key (ca-cert.crt) self signed.
openssl x509 -in $HOME/cert/ca.crt -text -noout

#Step5: To verify the cert use the below cert decoder
#https://www.sslshopper.com/certificate-decoder.html

#Step6: Deleting CSR file
rm -f $HOME/cert/ca.csr