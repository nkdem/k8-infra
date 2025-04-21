#!/bin/bash

# Script to port-forward Argo CD UI locally

# Namespace where Argo CD is installed (usually argocd)
ARGOCD_NAMESPACE="argocd"
# Name of the Argo CD UI service (usually argocd-server)
ARGOCD_SERVICE="argocd-server"
# Local port to forward to
LOCAL_PORT="8080"
# Target port of the Argo CD service (usually 80 or 443 for HTTP/S)
TARGET_PORT="80" # Assuming HTTP port for port-forwarding

echo "Attempting to port-forward Argo CD Service ${ARGOCD_SERVICE} in namespace ${ARGOCD_NAMESPACE} to local port ${LOCAL_PORT}..."

# Check if KUBECONFIG is set
if [ -z "$KUBECONFIG" ]; then
  echo "Error: KUBECONFIG environment variable is not set."
  echo "Please set KUBECONFIG to point to your k3s cluster's kubeconfig file."
  exit 1
fi

# Use kubectl port-forward
# You might need to add --address 0.0.0.0 if running inside a container or VM
kubectl port-forward service/${ARGOCD_SERVICE} -n ${ARGOCD_NAMESPACE} ${LOCAL_PORT}:${TARGET_PORT} &

# Store the process ID of the port-forward command
PORT_FORWARD_PID=$!

# Wait a moment for the tunnel to establish
sleep 3

# Check if the port-forward command is still running
if ! ps -p $PORT_FORWARD_PID > /dev/null; then
  echo "Error: kubectl port-forward command failed to start."
  exit 1
fi

echo "Port forwarding established. Argo CD UI should be available at http://localhost:${LOCAL_PORT}"

# Attempt to open the browser (works on most desktop environments)
# case "$(uname -s)" in
#    Linux*)     xdg-open http://localhost:${LOCAL_PORT};;
#    Darwin*)    open http://localhost:${LOCAL_PORT};;
#    CYGWIN*)    start http://localhost:${LOCAL_PORT};;
#    MINGW*)     start http://localhost:${LOCAL_PORT};;
#    *)          echo "Could not automatically open browser. Please open http://localhost:${LOCAL_PORT} manually.";;
# esac

# Keep the script running until the port-forward command is terminated (e.g., with Ctrl+C)
# The trap command ensures the port-forward process is killed when the script exits
trap "echo 'Stopping port forwarding...'; kill $PORT_FORWARD_PID" EXIT

wait $PORT_FORWARD_PID

echo "Port forwarding stopped."

