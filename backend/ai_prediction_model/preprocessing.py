import os
import random
import cv2
from PIL import Image, ImageEnhance, ImageFilter
import numpy as np
import shutil
from random import sample


#creating folders for new dataset
def create_folders(model_name):
    base_dir = '/app/data'
    paths = [
        os.path.join(base_dir, model_name, "train", "correct"),
        os.path.join(base_dir, model_name, "train", "incorrect"),
        os.path.join(base_dir, model_name, "val", "correct"),
        os.path.join(base_dir, model_name, "val", "incorrect")
    ]

    try:
        for path in paths:
            os.makedirs(path, exist_ok=True)
        print(f"Folders created successfully for model {model_name}")
        return True
    
    except Exception as e:
        error_message = f"Failed to create folders for model {model_name}"
        print(error_message)
        return {'error': error_message}

#extracting from videos. increasing the num_frames is recommended
def extract_frames(video_file, num_frames=100):
    #first have to convert the video file-like object into a temp file
    video_file_path = "/tmp/temp_video.mp4"
    with open(video_file_path, "wb") as f:
        f.write(video_file.read())

    cap = cv2.VideoCapture(video_file_path)

    if not cap.isOpened():
        return {'error': 'Could not open video file'}
    
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    num_frames = min(num_frames, total_frames)

    frame_indices = sorted(random.sample(range(total_frames), num_frames))

    extracted_frames = []

    for idx in frame_indices:
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)

        ret, frame = cap.read()

        if ret:
            frame = cv2.rotate(frame, cv2.ROTATE_180)
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            extracted_frames.append(frame)
        else:
            return {'error': f'Could not read frame at index {idx}'}
    
    cap.release()

    return extracted_frames

#80/20 train/val split
def divide_dataset(extracted_frames, model_name, train_ratio=0.8):
    random.shuffle(extracted_frames)
    train_size = int(len(extracted_frames) * train_ratio)

    train_set = extracted_frames[:train_size]
    val_set = extracted_frames[train_size:]

    base_dir = f'/app/data/{model_name}'
    train_correct_dir = os.path.join(base_dir, 'train/correct')
    val_correct_dir = os.path.join(base_dir, 'val/correct')

    #save train set
    for i, frame in enumerate(train_set):
        img = Image.fromarray(frame)
        img.save(os.path.join(train_correct_dir, f'frame_{i}.png'))

    #save val set
    for i, frame in enumerate(val_set):
        img = Image.fromarray(frame)
        img.save(os.path.join(val_correct_dir, f'frame_{i}.png'))

    return train_set, val_set 


def augment_frames(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".png"):
            img_path = os.path.join(directory, filename)
            img = Image.open(img_path)
            base_name = os.path.splitext(filename)[0]
            
            width, height = img.size
            new_width = new_height = 320
            left = (width - new_width) / 2
            top = (height - new_height) / 2
            right = (width + new_width) / 2
            bottom = (height + new_height) / 2

            # Crop
            img_cropped = img.crop((left, top, right, bottom))
            img_cropped.save(os.path.join(directory, f"{base_name}_cropped.png"))

            # Brightness adjustments
            enhancer = ImageEnhance.Brightness(img)
            img_bright = enhancer.enhance(1.7)
            img_bright.save(os.path.join(directory, f"{base_name}_brighter.png"))
            img_dark = enhancer.enhance(0.3)
            img_dark.save(os.path.join(directory, f"{base_name}_darker.png"))

            # Contrast
            enhancer = ImageEnhance.Contrast(img)
            img_contrast = enhancer.enhance(2)
            img_contrast.save(os.path.join(directory, f"{base_name}_contrast.png"))

            # Flip around y-axis
            img_flipped = img.transpose(Image.FLIP_LEFT_RIGHT)
            img_flipped.save(os.path.join(directory, f"{base_name}_flipped.png"))

            # Saturation
            enhancer = ImageEnhance.Color(img)
            img_saturation = enhancer.enhance(2.5)
            img_saturation.save(os.path.join(directory, f"{base_name}_saturation.png"))

            # Noise
            np_image = np.array(img)
            noise = np.random.normal(0, 40, np_image.shape)
            img_noise = Image.fromarray(np.clip(np_image + noise, 0, 255).astype(np.uint8))
            img_noise.save(os.path.join(directory, f"{base_name}_noise.png"))

            # Blur
            img_blur = img.filter(ImageFilter.GaussianBlur(radius=3))
            img_blur.save(os.path.join(directory, f"{base_name}_blurred.png"))

            # Rotation
            img_rotation = img.rotate(15, expand=True)
            img_rotation.save(os.path.join(directory, f"{base_name}_rotated.png"))

#we reuse the incorrect dataset from warrior_pose in new poses
def copy_images(source_dir, dest_dir, num_images):
    try:
        # Ensure destination directory exists
        os.makedirs(dest_dir, exist_ok=True)
        
        # Get list of all image files in source directory
        all_files = [f for f in os.listdir(source_dir) if os.path.isfile(os.path.join(source_dir, f)) and f.lower().endswith(('.png', '.jpg', '.jpeg'))]

        print(f"Files found in {source_dir}: {len(all_files)}")
        
        # Select a sample of images
        files_to_copy = sample(all_files, min(num_images, len(all_files)))
        
        for file_name in files_to_copy:
            full_file_name = os.path.join(source_dir, file_name)
            if os.path.isfile(full_file_name):
                shutil.copy(full_file_name, dest_dir)
        
        print(f"Copied {len(files_to_copy)} images to {dest_dir}")
        return {'result': f"Copied {len(files_to_copy)} images to {dest_dir}"}
    except Exception as e:
        error_message = f"Error occurred while copying images: {e}"
        print(error_message)
        return {'error': error_message}
