# Traefik reverse proxy
A Traefik Docker configuration that acts as the entrypoint for my development environment.


## Setup
The setup process is pretty simple, we will only have to execute a couple of steps to get it up and running.

### Create the Docker network
First we will need to make the `traefik-reverse-proxy` Docker network.
You can do this with the following command:
```
docker network create traefik-reverse-proxy
```

### Configure the environment file
Configuring the basicauth credentials, IP binding and more are all configured using the `.env` file.

In order to get started, make a copy of `.env.example` and call it `.env`.

The default credentials should be fine for a development setup, but might need to be adjusted for non-development environments.

### Generate a TLS certificate
We will generate a certificate in order to allow HTTPS requests on our development environment.
The certificate will be a wildcard certificate, this is done so that all your development applications can use this certificate.

Depending on your preference, you can select between `localhost`, `dev` and `test` as the top level domain.
```sh
cd tls

# If you want to use .localhost, run
./generate_wildcard_localhost_certificate.sh

# If you want to use .dev, run
# ./generate_wildcard_dev_certificate.sh

# If you want to use .test, run
# ./generate_wildcard_test_certificate.sh
```

> [!IMPORTANT]  
> We assume that you use the ".localhost" top level domain in this container.
>
> If you use something else, you will also have to update the domains inside the `.env` file of this repository and all the project that you are hosting.


### Start the container
Once you have done all of that, you are ready to get started!

Simply run the following command to start the Traefik container:
```
docker-compose up -d
```


## Traefik dashboard
If you want to see which containers are using Traefik at the moment, you can visit the Traefik dashboard.

![Screenshot of the Traefik dashboard](./assets/traefik_dashboard_preview.png)


You can visit the Traefik dashboard at [https://traefik.localhost](https://traefik.localhost).

> [!NOTE]  
> The Traefik Dashboard requires you to log in, the default credentials are as follows:
>
> **Username:** `traefik`
>
> **Password:** `PLEASE_change_THE_default_CREDENTIALS!`

> [!WARNING]  
> It's **highly recommended** that you change the credentials to something else.
> Using the default value could lead to someone unauthorized entering the Traefik dashboard.

## Jaeger UI
[Jaeger](https://www.jaegertracing.io) is also available in order to monitor and troubleshoot requests that are made to your services.

![Screenshot of the Jaeger UI](./assets/jaeger_ui_preview.png)


You can visit the Jaeger UI at [https://jaeger.localhost](https://jaeger.localhost).

> [!NOTE]  
> The Jaeger UI requires you to log in, the default credentials are as follows:
>
> **Username:** `jaeger`
>
> **Password:** `PLEASE_change_THE_default_CREDENTIALS!`

> [!WARNING]  
> It's **highly recommended** that you change the credentials to something else.
> Using the default value could lead to someone unauthorized entering the Jaeger UI.


## Change the default credentials
It's **highly recommended** that you change the default credentials to something else, so in this section we are going to explain how you can change them.

Run the following command to generate the required output for Traefik. Make sure to also replace `your_username_here` with your desired username.
```sh
echo $(htpasswd -nB your_username_here) | sed -e s/\\$/\\$\\$/g
```

The command will then ask for a password, enter your desired password and then you should receive a string that looks something like this:
```
your_username_here:$$2y$$05$$KlVS5bAXb8TL5h.vzzUMxOiOKWB6fA67zakKSY5y3oRWqBfGwD3Zu
```

Now update your `TRAEFIK_DASHBOARD_BASICAUTH_USERS` and/or `JAEGER_UI_BASICAUTH_USERS` variables in the `.env` file.

Once you have done that, restart the container and you should now be able to log in with your new credentials.


## Forward non-Docker requests to upstream server
If the container is unable to find any Docker containers that matches the incoming request, it will forward the HTTP request to the host machine on port `81`.

This allows you to for example use an Apache website running on the host machine as well as Docker applications on the same server, without forcing the user to manually specify the Apache port.

Traefik will automatically upgrade the request of the user to HTTPS using the `traefik_wildcard` certificate and key stored in the `tls` directory. You generated these certificates during the setup process of this container.


## Troubleshooting
You may run into issues while setting up this container, the more common issues have been documented here.

### Network not found
If you attempt to start the container and get an error like this:
```
Error response from daemon: network traefik-reverse-proxy not found
```

Then you most likely forgot to create the `traefik-reverse-proxy` Docker network before starting the container for the first time.
Check if you executed all the steps in the setup section and then try again.


### Ports are not available (Permission denied)
If you are using Docker Desktop and you get an error like this:
```
Error response from daemon: Ports are not available: exposing port TCP 127.0.0.1:443 -> 0.0.0.0:0: listen tcp 127.0.0.1:443: bind: permission denied
```

Then make sure that you use the Docker engine of the host machine and not the build in one from Docker Desktop.
This is because ports below 1024 are considered "privileged" on Linux and require higher permissions that the Docker Desktop engine doesn't have.

Using the system/default Docker engine should resolve the issue.
![Screenshot of the option you have to click in the Docker Desktop interface](./assets/docker_desktop_change_docker_engine.png)

### Traefik dashboard / Jaeger UI don't accept my credentials
If you try to access the Traefik dashboard or Jaeger UI, and it doesn't accept any credentials, then make sure that the `.env` has been configured properly.

The credentials they use are configured in the `.env`, and if they aren't set, Traefik will not accept any entered credentials.
