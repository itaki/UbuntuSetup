#!/bin/bash
echo "=== Forge Optimization Verification ==="
echo
echo "Command line arguments:"
grep "COMMANDLINE_ARGS" webui-user.sh | head -1
echo
echo "TCMalloc configuration:"
grep "LD_PRELOAD" webui-user.sh | head -1
grep "TCMALLOC" webui-user.sh
echo
echo "CUDA configuration:"
grep "CUDA_" webui-user.sh
echo
echo "PyTorch configuration:"
grep "PYTORCH_" webui-user.sh
grep "TORCH_" webui-user.sh
echo
echo "Cache directories:"
grep "mkdir" webui-user.sh
echo
echo "=== Verification Complete ==="
