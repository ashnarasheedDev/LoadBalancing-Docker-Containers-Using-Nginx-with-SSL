### Decscription

Nginx can be used as a great load balancer to distribute incoming traffic to servers and returning responses from the selected server to client. Nginx has some advantages than other load balancers.

**There are several advantages of load balancing using NGINX:**

   **Improved Performance:** NGINX acts as a reverse proxy and distributes incoming requests among multiple backend servers. This load balancing mechanism helps evenly distribute the traffic, preventing any single server from being overwhelmed. It improves response times and ensures optimal resource utilization, resulting in better overall performance of the application.

   **High Availability:** Load balancing with NGINX enhances the availability of your application. If one backend server becomes unavailable or experiences issues, NGINX can automatically route requests to other healthy servers. This redundancy ensures that your application remains accessible even in the event of server failures or maintenance activities.

   **Scalability:** NGINX enables horizontal scaling by allowing you to add or remove backend servers dynamically. As your application demand increases, you can easily scale by adding more servers to the pool. NGINX will intelligently distribute incoming requests to the available servers, accommodating the increased load.

   **SSL Termination:** NGINX can handle SSL termination, offloading the SSL/TLS encryption and decryption process from the backend servers. This reduces the computational load on the backend servers, improving their performance and scalability.

   **Flexible Load Balancing Algorithms:** NGINX offers various load balancing algorithms, such as round-robin, least connections, IP hash, and more. These algorithms allow you to customize the load balancing behavior based on your application requirements, ensuring efficient distribution of traffic.

   **Logging and Monitoring:** NGINX offers comprehensive logging and monitoring capabilities. You can gather detailed metrics, monitor server health, track request/response data, and analyze logs to gain insights into the performance and behavior of your application.


**Let’s create an example with docker and a simple python Flask app to test this method and see how they affect our requests:**

**Here is a simple diagram illustrates the setup**
![alt text](https://i.ibb.co/v3NJ8bz/nginx-albnew-1.jpg)

><b>Install Docker on Host machine</b>

```
yum install docker -y
systemctl enable docker.service
systemctl restart docker.service
```
We can follow these steps then:

  1.  Obtain SSL certificate and keys:
        Obtain an SSL certificate for domain "flask.ashna.online" from a trusted certificate authority or use Let's Encrypt for free SSL   certificates.
        Install the SSL certificate and obtain the SSL key files.

  2.  Create the backend containers:
        Build three Docker images, each containing a simple Python Flask app running on port 5000 with different versions.
        Run the containers based on the images, ensuring they expose port 5000.

  3.  Set up NGINX container:
        Build a Docker image for the NGINX container with a custom configuration.
        In the NGINX configuration, add an upstream block to define the backend servers:
        Configure NGINX to listen on ports 80 and 443, and set up SSL termination using the obtained SSL certificate and keys.
        Add a location block to proxy pass requests to the backend servers

  4.  Run the NGINX container:

        Run the NGINX container, ensuring it is linked to the backend containers.

  5. Update DNS and configure firewall:

        Update the DNS settings for "flask.ashna.online" to point to the public IP address of host server.
        Configure the firewall settings to allow inbound traffic on ports 80 and 443.
    
    
### Step 1 - Obtaining an SSL certificate

To obtain an SSL certificate for your domain, there are several methods you can choose from. Here are some commonly used options:

 - Let's Encrypt: Let's Encrypt is a free and widely used certificate authority that provides automated SSL certificates. You can use Certbot, a tool developed by Let's Encrypt, to easily obtain and manage SSL certificates. Certbot offers a straightforward command-line interface for requesting and renewing certificates.

 - Commercial Certificate Authorities: There are various commercial certificate authorities, such as Comodo, DigiCert, and GeoTrust, that offer SSL certificates for purchase. You can choose a certificate authority, follow their instructions, and pay a fee to obtain an SSL certificate.

 - Manual Certificate Generation: You can generate SSL certificates manually using tools like OpenSSL. This method requires more technical expertise and involves creating a Certificate Signing Request (CSR) and generating the SSL certificate and private key. While it provides more control, it can be more complex and time-consuming.

 - Self-Signed Certificates: Self-signed certificates are generated by yourself and not by a trusted certificate authority. They are not recommended for production environments as they are not recognized by default by web browsers and may trigger security warnings for users. Self-signed certificates are more suitable for local development or testing purposes.
    
 I used Certbot tool to get the certficate following below steps:
 ```
 # certbot -d flask.ashna.online --manual --preferred-challenges dns certonly
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for flask.ashna.online
 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name:
 
_acme-challenge.flask.ashna.online.
 
with the following value:
 
-DfgDAvlm2nuQFzjUqnIOSzyKqeWZOWXh4T93FRVWdM

Press Enter to Continue
 
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/flask.ashna.online/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/flask.ashna.online/privkey.pem
This certificate expires on 2023-08-30.
These files will be updated when the certificate renews.
 ```
### Step 2 - Creating three Backend Containers to run our Python Appication

><b> Create a simple app.py and requests.txt</b>

```
$ cat app.py 

from flask import Flask
import os
app = Flask(__name__)

@app.route('/')
def index():
    
  return '<h1><center>This is Flask Application - Version1 Nginx</center></h1>'

flask_port = os.getenv('FLASK_PORT',5000)
app.run(host='0.0.0.0', port=flask_port)

$ cat requests.txt 
Flask
```
><b> Create Dockerfile to build images</b>

   **FROM alpine:latest:** Sets the base image for the Docker image as the latest version of Alpine Linux.

   **ENV FLASK_DOCUMENTROOT /var/flaskapp:** Sets an environment variable FLASK_DOCUMENTROOT to specify the document root directory for the Flask application.

   **ENV FLASK_USER flask:** Sets an environment variable FLASK_USER to specify the username for the Flask application user.

   **ENV FLASK_PORT 5000:** Sets an environment variable FLASK_PORT to specify the port on which the Flask application will listen.

   **RUN mkdir -p $FLASK_DOCUMENTROOT:** Creates the directory specified by FLASK_DOCUMENTROOT to be used as the document root.

   **RUN adduser -h $FLASK_DOCUMENTROOT -D -s /bin/sh $FLASK_USER:** Adds a new user with the username specified by FLASK_USER and sets the home directory to FLASK_DOCUMENTROOT.

   **WORKDIR $FLASK_DOCUMENTROOT:** Sets the working directory for subsequent commands to FLASK_DOCUMENTROOT.

   **COPY ./code/ .:** Copies the contents of the ./code/ directory (the Flask application code) into the current working directory ($FLASK_DOCUMENTROOT).

   **RUN chown -R $FLASK_USER:$FLASK_USER $FLASK_DOCUMENTROOT:** Changes the ownership of the files in the document root directory to the user specified by FLASK_USER.

   **RUN apk update && apk add python3 py3-pip --no-cache:** Updates the Alpine package index and installs Python 3 and pip3.

   **RUN pip3 install -r requests.txt:** Installs the Python dependencies listed in the requests.txt file using pip3.

   **USER $FLASK_USER:** Sets the user to the one specified by FLASK_USER for subsequent commands.

   **EXPOSE $FLASK_PORT:** Exposes the port specified by FLASK_PORT to allow incoming connections.

   **ENTRYPOINT ["python3"]:** Specifies the entrypoint command for the container, which is python3.

   **CMD ["app.py"]:** Specifies the default command to be executed when the container starts, which is python3 app.py.

```
FROM alpine:latest

ENV FLASK_DOCUMENTROOT /var/flaskapp

ENV FLASK_USER flask

ENV FLASK_PORT 5000

RUN mkdir -p $FLASK_DOCUMENTROOT

RUN adduser -h $FLASK_DOCUMENTROOT  -D  -s /bin/sh  $FLASK_USER

WORKDIR $FLASK_DOCUMENTROOT

COPY ./code/ .

RUN chown -R  $FLASK_USER:$FLASK_USER $FLASK_DOCUMENTROOT

RUN apk update && apk add python3 py3-pip --no-cache

RUN pip3 install -r requests.txt

USER $FLASK_USER

EXPOSE $FLASK_PORT

ENTRYPOINT ["python3"]

CMD ["app.py"]
```
><b> Create Three images for Three containers so as the websites print Version 1, Version 2 and Version 3 respctively.</b>

To build the Docker image using this Dockerfile, navigate to the directory where the Dockerfile is saved and run the following command:
    
```
docker image build -t nginxflask:1 .
```

Repeat for Version2 and 3

><b> Create a Custom network</b>

Custom networks enable containers to communicate with each other using their container names as hostnames.

```
$ docker network create flask-network
09ec9558c3d693035ea4654c6e155d2be25c78ec8afec05886a28a4171b2b9a3
```

><b>Create 3 Backend containers using three images built</b>

Run three Docker containers named website1, website2, and website3 based on the nginxflask image with different versions (1, 2, and 3) on the flask-network network. Here's a breakdown of the commands:
    
docker container run --name website1 -d --network flask-network nginxflask:1: Runs a Docker container named website1 in the background (-d) using the nginxflask:1 image. The container is connected to the flask-network network.
    
```
# docker container run --name website1 -d --network flask-network nginxflask:1
c281123302f3bb242c894a368de4fff4905114858517f276e51ae84607619d66

# docker container run --name website2 -d --network flask-network nginxflask:2
ecbc06c8fba3ac84c7fea8baa43d1221567d330491982ce474080858664f668d

# docker container run --name website3 -d --network flask-network nginxflask:3
1d588e44e69ffa1df3424df58e2b9055d0dd22433e2146e137b68caee693985a
```
### Step 3 - Setup the Nginx Container

><b>Create Default NGINX Configuration file</b>

  - The server block defines the server configuration for the domain flask.ashna.online. It listens on ports 80 and 443 for HTTP and HTTPS traffic, respectively.
  - The if block checks if the request scheme is not HTTPS and redirects it to HTTPS using a permanent redirect.
  - The ssl_certificate and ssl_certificate_key directives specify the paths to the SSL certificate and private key files for enabling HTTPS.
  - The location / block handles all requests for the root URL or any path under it.
  - The proxy_set_header directives are used to pass the necessary headers to the backend Flask application for proper request handling.
  - The proxy_pass directive specifies the backend server or upstream group (flaskapp) to which the requests will be forwarded.
  - The error_page and location = /50x.html blocks define error page handling for server errors.
   - The upstream flaskapp block specifies the backend servers (website1, website2, website3) and their respective ports (5000) for load balancing.
   - 
This Nginx configuration acts as a reverse proxy and load balancer for the Flask application running on the backend containers (website1, website2, website3). It enables HTTPS traffic, forwards requests to the backend servers.

```
server {
    listen      80;
    listen  443 ssl;
 
 if ($scheme != "https") {
    rewrite ^ https://$host$uri permanent;
    }
  server_name  flask.ashna.online;
 
ssl_certificate /var/fullchain.pem;
ssl_certificate_key /var/privkey.pem;
    location / {
     proxy_set_header HOST $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://flaskapp;
}
   
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
 
   
}
 
upstream flaskapp {
  server website1:5000;
  server website2:5000;
  server website3:5000;
}
```

### Step 4 - Create Nginx Container

```
$ docker container run -d --name nginx -p 80:80 -p 443:443 --network flask-network -v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf -v $(pwd)/fullchain.pem:/var/fullchain.pem -v $(pwd)/privkey.pem:/var/privkey.pem nginx:alpine
```
 **-d:** Runs the container in detached mode, which means it runs in the background.
 
 **--name nginx:** Sets the name of the container as "nginx".
 
 **-p 80:80 -p 443:443:** Maps the host's ports 80 and 443 to the container's ports 80 and 443, respectively. This allows HTTP and HTTPS traffic to reach the container.
 
  **--network flask-network:** Connects the container to the "flask-network" Docker network. This allows communication between the Nginx container and the backend Flask application containers.
  
 **-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf:** Mounts the "default.conf" file from the host to the container's "/etc/nginx/conf.d/default.conf" path. This file contains the Nginx configuration for reverse proxying and load balancing.
 
  **-v $(pwd)/fullchain.pem:/var/fullchain.pem:** Mounts the "fullchain.pem" SSL certificate file from the host to the container's "/var/fullchain.pem" path. This provides the SSL certificate for HTTPS encryption.
  
 **-v $(pwd)/privkey.pem:/var/privkey.pem:** Mounts the "privkey.pem" private key file from the host to the container's "/var/privkey.pem" path. This provides the private key for HTTPS encryption.
 
 **nginx:alpine:** Specifies the image to use for the container. In this case, it uses the "nginx:alpine" image, which is a lightweight version of Nginx based on Alpine Linux.

By running this command, we're starting an Nginx container that will listen on ports 80 and 443, use the provided configuration file and SSL certificate files, and connect to the "flask-network" Docker network. It will act as a reverse proxy and load balancer for your Flask application containers.

### Results
```
$ docker container ls
CONTAINER ID   IMAGE          COMMAND                  CREATED       STATUS       PORTS                                                                      NAMES
b4bbf4167839   nginx:alpine   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp   nginx
1d588e44e69f   nginxflask:3   "python3 app.py"         4 hours ago   Up 4 hours   5000/tcp                                                                   website3
ecbc06c8fba3   nginxflask:2   "python3 app.py"         4 hours ago   Up 4 hours   5000/tcp                                                                   website2
c281123302f3   nginxflask:1   "python3 app.py"         4 hours ago   Up 4 hours   5000/tcp                                                                   website1
```

I'm attaching screenshots of websites load when I call flask.ashna.online

![alt text](https://i.ibb.co/VmJsGvK/nginx2.png)


![alt text](https://i.ibb.co/2NC10xy/nginx3.png)


![alt text](https://i.ibb.co/g3tTJ5d/nginx1.png)
