# dst-server
Dockerfile for Don't Starve Together dedicated server

## Usage
The purpose of this Dockerfile is for easy installing.  There are only
a few setting can be configured.

To launch a dedicated server, you should get a cluster token first.  The
token can be get from `https://accounts.klei.com/account/game/config?game=DontStarveTogether`

### Parameter
All the needed parameters are set by environ variable when launching 
docker container.

| Parameter     | Description                            |
|:--------------|:---------------------------------------|
| CLUSTER\_TOKE | the token get from [klei](https://accounts.klei.com/account/game/config?game=DontStarveTogether) server. |
| CLUSTER\_NAME | the name shown on DST Server List.     |
| CLUSTER\_PASS | the password used to join the cluster. |

### Example
```bash
docker run -it --env CLUSTER_TOKE=<token> --env CLUSTER_NAME=<name> --env CLUSTER_PASS=<pass> chhu0830/dst-server
```
