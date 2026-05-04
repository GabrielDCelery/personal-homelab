# ComfyUI

ComfyUI runs as a Docker container using the `yanwk/comfyui-boot:cu128-slim` image, exposed on port `8189`.

## Custom Nodes

Custom nodes are installed via ComfyUI-Manager (pre-installed in the image) and persist in `/srv/comfyui/nodes/custom_nodes` on the host.

### Installed nodes

| Node             | Repository                                          |
| ---------------- | --------------------------------------------------- |
| Efficiency Nodes | https://github.com/jags111/efficiency-nodes-comfyui |

### Installing a custom node

1. Open ComfyUI at `http://<host>:8189`
2. Click **Manager** in the menu bar
3. Click **Install Custom Nodes**
4. Search for the node by name or author
5. Click **Install** — ComfyUI-Manager handles pulling the repo and installing dependencies automatically
6. Restart the container for the node to take effect
7. **Add the node to the installed nodes table above**

## Models

Models live at `/srv/comfyui/models/models` on the host, mounted into the container at `/root/ComfyUI/models`.

To copy models from the old host installation:

```sh
sudo rsync -aAXv /home/gaze/projects/ComfyUI/models/ /srv/comfyui/models/models/
sudo chown -R root:root /srv/comfyui/models/models/
```
