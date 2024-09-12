import torch
from torchvision import transforms
from ultralytics import YOLO
from PIL import Image
import io
import os
from backend.save_model import save_model
from backend.ai_prediction_model.preprocessing import create_folders, extract_frames, divide_dataset, augment_frames, copy_images

def process_image(file, model_name):
    model_path = '/app/saved_models/' + model_name + '.pt'
    model = YOLO(model_path) #doing this alternative way to test

    try:
        # Convert the file to a PIL Image
        img = Image.open(io.BytesIO(file.read()))
        
        if img.format == 'PNG':
            img = img.convert('RGB')
            img_byte_arr = io.BytesIO()
            img.save(img_byte_arr, format='JPEG')
            img_byte_arr.seek(0)
            img = Image.open(img_byte_arr)

        # Transform the image as needed for your model
        transform = transforms.Compose([
            transforms.Resize((320, 320)),
            transforms.ToTensor()
        ])
        img = transform(img).unsqueeze(0)  # Add batch dimension

        # Run the image through the model
        with torch.no_grad():
            results = model(img)
            result = results[0]

            #logic will depend on model output -> Talk with Beth
            # prediction = results[0].argmax(dim=1).item() #will have to change this, probably
            # is_correct = bool(prediction)
            top1 = result.probs.top1
            is_correct = not bool(top1)

        # logging.info(f'Prediction result: {"correct" if is_correct else "incorrect"}')
        return {'result': 'Correct' if is_correct else 'Incorrect'} #can output results directly
    
    except Exception as e:
        return {'error': str(e)}

    
def train_new_model(video_file, model_name):
    try:
        #extract frames from video
        extracted_frames = extract_frames(video_file)
        if 'error' in extracted_frames: #this line prints in output
            return {'error': extracted_frames['error']}
        
        #divide frames into train/val
        create_folders_result = create_folders(model_name)
        if isinstance(create_folders_result, dict) and 'error' in create_folders_result:
            return create_folders_result
        divide_dataset(extracted_frames, model_name)

        #perform data augmentation on train
        train_correct_dir = f'/app/data/{model_name}/train/correct'
        augment_frames(train_correct_dir)

        #copy test/val incorrect images
        source_train_incorrect = "/app/data/train/incorrect"
        source_val_incorrect = "/app/data/val/incorrect"
        dest_train_incorrect = f"/app/data/{model_name}/train/incorrect"
        dest_val_incorrect = f"/app/data/{model_name}/val/incorrect"

        print(f"Copying images from {source_train_incorrect} to {dest_train_incorrect}")
        copy_images(source_train_incorrect, dest_train_incorrect, 800)

        print(f"Copying images from {source_val_incorrect} to {dest_val_incorrect}")
        copy_images(source_val_incorrect, dest_val_incorrect, 20)

        #train model
        #return True if all steps went well or False if something went wrong (indicate what if so)
        print("Training model...")
        if save_model(model_name):
            return {'result': 'Model trained successfully'}
        
    except Exception as e:
        return {'error': str(e)}
