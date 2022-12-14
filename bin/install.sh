#!/usr/bin/bash

STABLE_DIFFUSION_DIR=~/stablediffusion
OPENAI_DIR=$STABLE_DIFFUSION_DIR/openai
CLIP_VIT_LARGE=$OPENAI_DIR/clip-vit-large-patch14
RUNWAYML_DIR=$STABLE_DIFFUSION_DIR/runwayml
STABILITY_AI_DIR=$STABLE_DIFFUSION_DIR/stabilityai

SD_MODEL_V1=$RUNWAYML_DIR/stable-diffusion-v1-5
INPAINT_MODEL_V1=$RUNWAYML_DIR/stable-diffusion-inpainting

SD_MODEL_V2=$STABILITY_AI_DIR/stable-diffusion-2-1-base
INPAINT_MODEL_V2=$STABILITY_AI_DIR/stable-diffusion-2-inpainting
DEPTH_MODEL_V2=$STABILITY_AI_DIR/stable-diffusion-2-depth
UPSCALER_MODEL_V2=$STABILITY_AI_DIR/stable-diffusion-x4-upscaler

V1_DIR=$STABLE_DIFFUSION_DIR/v1
V2_DIR=$STABLE_DIFFUSION_DIR/v2

CLIP_DIR=$STABLE_DIFFUSION_DIR/CLIP/clip/
VOCAB_MODEL=$CLIP_DIR/bpe_simple_vocab_16e6.txt.gz

COMPVIS_DIR=$STABLE_DIFFUSION_DIR/CompVis
SAFETY_CHECKER_DIR=$COMPVIS_DIR/stable-diffusion-safety-checker
SAFETY_CHECKER_MODEL=$SAFETY_CHECKER_DIR/pytorch_model.bin


# install the server with all models in the expected location

#-----------------------#
# Handle stablediffusion root directory

if [ ! -d "$STABLE_DIFFUSION_DIR" ]; then
    echo "Creating $STABLE_DIFFUSION_DIR"
    mkdir $STABLE_DIFFUSION_DIR
else
    echo "Directory $STABLE_DIFFUSION_DIR already exists."
fi

cd $STABLE_DIFFUSION_DIR

#-----------------------#
# Handle openai directory

if [ ! -d "OPENAI_DIR" ]; then
    echo "Creating $OPENAI_DIR"
    mkdir -p OPENAI_DIR
else
    echo "Directory $OPENAI_DIR already exists."
fi

cd $OPENAI_DIR

#-----------------------#
# Handle CLIP model

# check if clip-vit-large-patch14 exists
if [ ! -d "$CLIP_VIT_LARGE" ]; then
    git clone https://huggingface.co/openai/clip-vit-large-patch14
fi

#-----------------------#
# Handle runwayml directory

if [ ! -d "$RUNWAYML_DIR" ]; then
    echo "Creating $RUNWAYML_DIR"
    mkdir -p $RUNWAYML_DIR
else
    echo "Directory $RUNWAYML_DIR already exists."
fi

#-----------------------#
# HANDLE RunwayML stable-diffusion-v1-5 model

cd $RUNWAYML_DIR

# check if stable-diffusion-v1-5 exists
if [ ! -d "$SD_MODEL_V1" ]; then
    echo "Downloading stable-diffusion-v1-5"
    git clone https://huggingface.co/runway/stable-diffusion-v1-5 --branch fp16
else
    echo "Directory $SD_MODEL_V1 already exists."
fi

#-----------------------#
# HANDLE RunwayML inpainting model

if [ ! -d "$INPAINT_MODEL_V1" ]; then
    echo "Downloading stable-diffusion-inpainting"
    git clone https://huggingface.co/runway/stable-diffusion-inpainting --branch fp16
else
    echo "Directory $INPAINT_MODEL_V1 already exists."
fi

#-----------------------#
# HANDLE StabilityAI directory

if [ ! -d "$STABILITY_AI_DIR" ]; then
    echo "Creating $STABILITY_AI_DIR"
    mkdir -p $STABILITY_AI_DIR
else
    echo "Directory $STABILITY_AI_DIR already exists."
fi

cd $STABILITY_AI_DIR

#-----------------------#
# HANDLE StabilityAI stable-diffusion-2-1-base model

if [ ! -d "$SD_MODEL_V2" ]; then
    echo "Downloading stable-diffusion-2-1-base"
    git clone https://huggingface.co/stabilityai/stable-diffusion-2-1-base --branch fp16
else
    echo "Directory $SD_MODEL_V2 already exists."
fi

#-----------------------#
# HANDLE StabilityAI inpainting model

if [ ! -d "$INPAINT_MODEL_V2" ]; then
    echo "Downloading stable-diffusion-2-inpainting"
    git clone https://huggingface.co/stabilityai/stable-diffusion-2-inpainting --branch fp16
else
    echo "Directory $INPAINT_MODEL_V2 already exists."
fi

#-----------------------#
# HANDLE StabilityAI depth model

if [ ! -d "$DEPTH_MODEL_V2" ]; then
    echo "Downloading stable-diffusion-2-depth"
    git clone https://huggingface.co/stabilityai/stable-diffusion-2-depth --branch fp16
else
    echo "Directory $DEPTH_MODEL_V2 already exists."
fi

#-----------------------#
# HANDLE StabilityAI upscaler model

if [ ! -d "$UPSCALER_MODEL_V2" ]; then
    echo "Downloading stable-diffusion-x4-upscaler"
    git clone https://huggingface.co/stabilityai/stable-diffusion-x4-upscaler --branch fp16
else
    echo "Directory $UPSCALER_MODEL_V2 already exists."
fi

#-----------------------#
# HANDLE Custom models v1 / v2 directories

#-----------------------#
# HANDLE v1 directory

if [ ! -d "$V1_DIR" ]; then
    echo "Creating $V1_DIR"
    mkdir -p $V1_DIR
else
    echo "Directory $V1_DIR already exists."
fi

#-----------------------#
# HANDLE v2 directory

if [ ! -d "$V2_DIR" ]; then
    echo "Creating $V2_DIR"
    mkdir -p $V2_DIR
else
    echo "Directory $V2_DIR already exists."
fi

#-----------------------#
# HANDLE CLIP directory

if [ ! -d "$CLIP_DIR" ]; then
    echo "Creating $CLIP_DIR"
    mkdir -p $CLIP_DIR
else
    echo "Directory $CLIP_DIR already exists."
fi

cd $CLIP_DIR

#-----------------------#
# HANDLE CLIP vocab model

if [ ! -f "$VOCAB_MODEL" ]; then
    echo "Downloading bpe_simple_vocab_16e6.txt.gz"
    git clone https://github.com/openai/CLIP.git
else
    echo "File $VOCAB_MODEL already exists."
fi

#-----------------------#
# HANDLE CompVis directory

if [ ! -d "$COMPVIS_DIR" ]; then
    echo "Creating $COMPVIS_DIR"
    mkdir -p $COMPVIS_DIR
else
    echo "Directory $COMPVIS_DIR already exists."
fi

cd $COMPVIS_DIR

#-----------------------#
# HANDLE stable-diffusion-safety-checker directory

if [ ! -d "$SAFETY_CHECKER_DIR" ]; then
  echo "Downloading stable-diffusion-safety-checker"
  git clone https://huggingface.co/CompVis/stable-diffusion-safety-checker
else
  echo "Directory $SAFETY_CHECKER_DIR already exists."
fi