#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#pre-processing the object tag files
#clean and combine the text files
import os
import re

def clean_and_combine_text_files():
    sets = range(1, 46)  # Loop from Set1 to Set45

    for set_num in sets:
        folder_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/Negative'  # Replace with the path to your folder containing the text files with object tags
        output_file_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/Negative/combined_text.txt'  # Replace with the desired output file path

        cleaned_files = []

        # Open the output file in write mode
        with open(output_file_path, 'w') as output_file:
            # Iterate over all files in the folder
            for file_name in os.listdir(folder_path):
                if file_name.endswith('.txt'):
                    file_path = os.path.join(folder_path, file_name)

                    # Read the file
                    with open(file_path, 'r') as file:
                        text = file.read()
                        
                    # Remove anything inside double quotes
                    cleaned_text = re.sub(r'\"[^"]*\"', '', text)

                    # Find all pairs between # # and replace them with a comma-separated list
                    word_pairs = re.findall(r'#(.*?)(?=#|$)', text)
                    unique_pairs = set(pair.strip() for pair in word_pairs)

                    # Remove any numbers or special characters from the pairs
                    cleaned_pairs = []
                    for pair in unique_pairs:
                        cleaned_pair = re.sub(r'[^a-zA-Z,\s]', '', pair).strip()
                        cleaned_pairs.append(cleaned_pair)

                    # Filter out empty pairs
                    cleaned_pairs = [pair for pair in cleaned_pairs if pair]

                    # Write the text to the output file with spaces between words
                    cleaned_text = ', '.join(cleaned_pairs).replace(',', ', ')

                    # Write the text to the output file
                    output_file.write(cleaned_text)
                    output_file.write(', ')  # Add a comma after each file

                    cleaned_files.append(file_path)

        print(f"Set{set_num} text files cleaned and combined successfully.")
        print(cleaned_files)

# Call the function
clean_and_combine_text_files()


# In[ ]:


# prompt for generating concepts
import os
import openai

# Function to read the text file
def read_text_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()

# Replace 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key
openai.api_key = 'Your OpenAI Key'

# Function to interact with ChatGPT and ask questions
def ask_question(prompt):
    response = openai.ChatCompletion.create(
        model = 'gpt-4',  # Use the appropriate GPT-4 model
        messages = [{'role': 'user', 'content': prompt}],
        temperature=0.5,
        top_p=1
    )
    response_text = response['choices'][0]['message']['content']
    return response_text

def process_sets():
    for set_num in range(1, 46):
        positive_file_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/Positive/combined_text.txt'
        negative_file_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/Negative/combined_text.txt'
        response_file_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/response_final_3.txt'

        # Read the contents of the positive and negative files
        positive_text = read_text_file(positive_file_path)
        negative_text = read_text_file(negative_file_path)

        # Construct the prompt question
        #prompt = f"Given the two sets of objects, Set1:{positive_text} and Set2:{negative_text}; give me the top seven general concepts that better represent what the objects in Set1:{positive_text} has that the objects in Set2:{negative_text} does not. Don't give me any decriptions, just the concept names."
        prompt = f"Given the two sets of objects found in two different class of images, Set1:{positive_text} and Set2:{negative_text}; give me the top seven class of objects or general scenario similar to each other that better represent what the images in Set1:{positive_text} has but the images in Set2:{negative_text} does not. Don't give me any descriptions, just the names."

        # Concatenate the text of both files and append it to the prompt
        #prompt += f"\nPositive Text:\n{positive_text}\nNegative Text:\n{negative_text}\nAnswer:" 

        # Ask the question to the ChatGPT model
        answer = ask_question(prompt)

        # Store the response in a separate file
        with open(response_file_path, 'w') as response_file:
            response_file.write(answer)

        print(f"Response for Set{set_num} saved to {response_file_path}")

# Call the function to process all sets
process_sets()


# In[ ]:


#post-processing 
#save the final result 
import os
import re

def clean_and_save_files():
    sets = range(29,30)  # Loop from Set1 to Set45

    for set_num in sets:
        input_file_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/response_final_3.txt'  # Replace with the path to your input files
        output_file_path = f'/Users/adrita/Desktop/ChatGptExplanation/Set{set_num}/final_result.txt'  # Replace with the desired output file path

        # Read the input file
        with open(input_file_path, 'r') as input_file:
            text = input_file.read()

        # Remove newlines and replace them with commas
        text = text.replace('\n', ', ')
        
        # Remove numbers and spaces after numbers using regular expression
        text = re.sub(r'\d+\s*', '', text)

        # Remove dots and spaces after dots
        text = text.replace('. ', '')

        # Write the cleaned text to the output file
        with open(output_file_path, 'w') as output_file:
            output_file.write(text)

        print(f"Set{set_num} file cleaned and saved as {output_file_path}")

# Call the function to process all sets
clean_and_save_files()

