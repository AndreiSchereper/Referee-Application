import shutil
import os
from ultralytics import YOLO

def save_model(pose_name: str) -> str:
    data_path = f"/app/data/{pose_name}" #Dataset file for the training and val images. Example: /data/warrior_pose
    epochs = 60  # MAX Number of training epochs 
    image_size = 320  # Size of the input images
    pretrained_model_path = 'yolov8n-cls.pt'  # The pre-trained model, this case it's YOLOv8 nano
    save_dir = 'saved_models'  # Directory to save the trained model
    save_name = f"{pose_name}.pt"  # Pose name for the saved model. Example: warrior_pose.pt
    patience = 3 # early stopping patience parameter
    weight_decay = 0.0005 # Weight decay for regularization

    try:
        # load the pre-trained YOLO model
        model = YOLO(pretrained_model_path)
    except Exception as e:
        return f"Failed to load model: {e}"

    try:
        #train the model with the specified parameters
        #the model is saved to a temporary file first, as temp_trained_model
        #this is to prevent saving the other files comes with training
        #and to save the model as the pose name (warrior_pose_model), and to save it to the requested directory
        temp_project_dir = os.path.join(save_dir, 'temp_trained_model') 
        model.train(data=data_path, epochs=epochs, imgsz=image_size, project=temp_project_dir, name='result', lr0=0.001, weight_decay=weight_decay, patience=patience)
    except Exception as e:
        return f"Error during training: {e}"

    # Define paths
    trained_model_path = os.path.join(temp_project_dir, 'result', 'weights', 'best.pt')
    new_model_path = os.path.join(save_dir, save_name)
    
    try:
        # create the directory if it doesn't exist
        os.makedirs(os.path.dirname(new_model_path), exist_ok=True)
        #move the trained model file to the new location
        shutil.move(trained_model_path, new_model_path)
        #clean up the temporary project directory
        shutil.rmtree(temp_project_dir)
    except Exception as e:
        return f"Failed to rename the model file: {e}"

    return True

