import json
import os
from firebase_admin import credentials, firestore, initialize_app

def initialize_firestore():
    """Initializes the Firebase Admin SDK and returns a Firestore client."""
    if 'GOOGLE_APPLICATION_CREDENTIALS' not in os.environ:
        raise EnvironmentError(
            "The GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.\n"
            "Please set it to the path of your service account key file."
        )
    
    service_account_key_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']

    if not os.path.exists(service_account_key_path):
        raise FileNotFoundError(
            f"Service account key file not found at: {service_account_key_path}\n"
            "Please download your service account key and place it in the correct directory."
        )
    
    try:
        cred = credentials.Certificate(service_account_key_path)
        initialize_app(cred)
        print("Firebase Admin SDK initialized successfully.")
        return firestore.client()
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        print("Please ensure your service account key is valid and has the necessary permissions.")
        exit(1)

def load_json_data(file_path):
    """Loads JSON data from the specified file."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"JSON data file not found at: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Successfully loaded data from {file_path}.")
    return data

def import_data_to_firestore(db, collection_name, data):
    """
    Imports a list of dictionaries into a Firestore collection.
    Each dictionary becomes a document.
    """
    batch = db.batch()
    batch_size = 0
    total_documents_imported = 0

    print(f"Starting import to collection: '{collection_name}'...")

    try:
        documents_to_import = data['__collections__'][collection_name]
    except KeyError:
        raise ValueError(
            f"Invalid JSON bundle structure. Expected '__collections__ -> {collection_name}', "
            "but structure was not found."
        )

    if 'documents' in documents_to_import:
        documents_to_import = documents_to_import['documents']
    else:
        raise ValueError(
            f"Invalid JSON bundle structure for collection '{collection_name}'. "
            "Expected 'documents' key not found."
        )

    for doc_id, doc_data in documents_to_import.items():
        doc_ref = db.collection(collection_name).document(doc_id)
        batch.set(doc_ref, doc_data)
        batch_size += 1

        if batch_size >= 499:
            print(f"Attempting to commit batch of {batch_size} documents (mid-loop).")
            try:
                batch.commit()
                total_documents_imported += batch_size
                print(f"Committed {batch_size} documents. Total imported: {total_documents_imported}")
                batch = db.batch()
                batch_size = 0
            except Exception as e:
                print(f"Error committing batch mid-loop: {e}")
                raise # Re-raise to stop execution and show error
    
    if batch_size > 0:
        print(f"Attempting to commit final batch of {batch_size} documents.")
        try:
            batch.commit()
            total_documents_imported += batch_size
            print(f"Committed final {batch_size} documents. Total imported: {total_documents_imported}")
        except Exception as e:
            print(f"Error committing final batch: {e}")
            raise # Re-raise to stop execution and show error

    print(f"Import complete. Total documents imported: {total_documents_imported} into collection '{collection_name}'.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Import JSON data into Firestore.')
    parser.add_argument('--input', required=True, help='Path to the JSON file to import.')
    parser.add_argument('--collection', required=True, help='Name of the Firestore collection to import into.')
    args = parser.parse_args()

    try:
        firestore_client = initialize_firestore()
        json_data = load_json_data(args.input)
        import_data_to_firestore(firestore_client, args.collection, json_data)
    except FileNotFoundError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
