import os
import glob
from ultralytics import YOLO
import cv2
import logging

#THIS SCRIPT IS USED MANUALLY ON THE TERMINAL TO TEST THE MODELS
#THIS SCRIPT IS **NOT** USED IN THE APPLICATION ITSELF WHILE ITS RUNNING
#to use this script, change the model_path variable in __main__ to the path of the model you want to evaluate
# and run this script on your terminal example: python test_model.py

#logging to display info in the terminal
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_image_paths(test_dir):
    try:
        # check if test dir exists
        if not os.path.isdir(test_dir):
            raise ValueError(f"test directory does not exist: {test_dir}")
        # get all ' *.jpg', '*.jpeg', '*.png' images in the test directory and subdirectories
        image_paths = glob.glob(os.path.join(test_dir, '**', '*.jpg'), recursive=True)
        if not image_paths:
            logging.warning(f"No images found in the test directory: {test_dir}")
        return image_paths
    except Exception as e:
        logging.error(f"Error getting image paths: {e}")
        return []

# the real class is the name of the parent directory of the frame (CORRECT/INCORRECT)
def get_actual_label(image_path):
    return os.path.basename(os.path.dirname(image_path))

def classify_images(model, image_paths):
    correct = 0
    total = 0
    
    for img_path in image_paths:
        try:
            #read frame
            img = cv2.imread(img_path)
            if img is None:
                logging.warning(f"Failed to read image: {img_path}")
                continue
            
            #make model check image
            result = model(img)
            
            # get class names and probabilities from the model's result
            names = result[0].names
            probability = result[0].probs.data.numpy()
            
            #get predicted class (higher possibility)
            predicted_label_idx = probability.argmax()
            predicted_label = names[predicted_label_idx]
            
            ##get actual c;ass
            actual_label = get_actual_label(img_path)
            
            #compare predicted and actual classes
            if predicted_label == actual_label:
                correct += 1
            total += 1
        except Exception as e:
            logging.warning(f"Error classifying image {img_path}: {e}")
            continue

    #get accuracy score
    accuracy = correct / total if total > 0 else 0
    return accuracy

def main():
    test_dir = 'data/test' #WRITE THE PATH OF THE TEST DATA 
    model_path = '' #WRITE THE PATH OF THE MODEL YOU WANT TO TEST

    try:
        logging.info(f"Loading model from {model_path}")
        # load the YOLO model
        model = YOLO(model_path)
    except Exception as e:
        logging.error(f"Failed to load model: {e}")
        return

    try:
        # Get all images
        image_paths = get_image_paths(test_dir)
        if not image_paths:
            logging.error("No images to classify.")
            return
        
        # Classify images and calculate accuracy
        accuracy = classify_images(model, image_paths)
        
        logging.info(f'Accuracy: {accuracy * 100:.2f}%')
    except Exception as e:
        logging.error(f"Error during classification: {e}")

if __name__ == "__main__":
    main()
