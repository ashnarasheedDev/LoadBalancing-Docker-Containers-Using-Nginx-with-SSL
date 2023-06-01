# LoadBalancing-Docker-Containers-Using-Nginx-with-SSL
Nginx can be used as a great load balancer to distribute incoming traffic to servers and returning responses from the selected server to client. Nginx has some advantages than other load balancers.

**There are several advantages of load balancing using NGINX:**

   **Improved Performance:** NGINX acts as a reverse proxy and distributes incoming requests among multiple backend servers. This load balancing mechanism helps evenly distribute the traffic, preventing any single server from being overwhelmed. It improves response times and ensures optimal resource utilization, resulting in better overall performance of the application.

   **High Availability:** Load balancing with NGINX enhances the availability of your application. If one backend server becomes unavailable or experiences issues, NGINX can automatically route requests to other healthy servers. This redundancy ensures that your application remains accessible even in the event of server failures or maintenance activities.

   **Scalability:** NGINX enables horizontal scaling by allowing you to add or remove backend servers dynamically. As your application demand increases, you can easily scale by adding more servers to the pool. NGINX will intelligently distribute incoming requests to the available servers, accommodating the increased load.

   **SSL Termination:** NGINX can handle SSL termination, offloading the SSL/TLS encryption and decryption process from the backend servers. This reduces the computational load on the backend servers, improving their performance and scalability.

   **Flexible Load Balancing Algorithms:** NGINX offers various load balancing algorithms, such as round-robin, least connections, IP hash, and more. These algorithms allow you to customize the load balancing behavior based on your application requirements, ensuring efficient distribution of traffic.

   **Logging and Monitoring:** NGINX offers comprehensive logging and monitoring capabilities. You can gather detailed metrics, monitor server health, track request/response data, and analyze logs to gain insights into the performance and behavior of your application.


**Let’s create an example with docker and a simple python Flask app to test this method and see how they affect our requests:**

We can follow these steps:

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
    
    
