# Local Build Issues #
## Problems ##
Following the instructions in the ReadMe.md file to build the Docker images or the local build appear to be successful.  While the Go Server runs and pushes requests into the Redis queue(s), the Python backend(s) fail, so no processing is done.
1. The *requirements.txt* file has the onnx-runtime pinned to 0.4.0, which can't be loaded. 
    1. Updated to use most recent.
    1. This is only used in the local, non-docker build as the *deepquestai/deepstack-base* docker image has all the requirements included.
1. The *.\download_dependencies.ps1* step overwrites files that is in the repository with files from *https://deepstack.blob.core.windows.net/shared-files/* meaning that the build is not self-contained.
    1. **This is required!!** the models are not stored in the repo.
    1. are these downloaded files covered under the same license?
