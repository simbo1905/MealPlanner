import os
import json
import firebase_admin
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
        # Check if the app is already initialized
        if not firebase_admin._apps:
            initialize_app(cred)
            print("Firebase Admin SDK initialized successfully.")
        return firestore.client()
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        print("Please ensure your service account key is valid and has the necessary permissions.")
        exit(1)

def validate_data(db):
    """Validates the imported data in Firestore."""
    collection_ref = db.collection('recipesv1')

    # 1. List first 5 recipes
    print("Listing first 5 recipes from recipesv1...")
    docs = collection_ref.limit(5).stream()
    for doc in docs:
        title_data = doc.get('title')
        title = title_data.get('stringValue') if isinstance(title_data, dict) else title_data
        print(f"  - {doc.id}: {title}")

    # 2. Count total number of recipes
    # Note: This is an expensive operation for large collections.
    # For this validation, we will just count the docs.
    print("\nCounting documents...")
    all_docs = collection_ref.stream()
    count = sum(1 for _ in all_docs)
    print(f"Total documents: {count}")


    # 3. Perform a prefix query for "chicken"
    print("\nPrefix query (chicken)...")
    query = collection_ref.where(filter=firestore.FieldFilter('titleLower.stringValue', '>=', 'chicken')) \
                          .where(filter=firestore.FieldFilter('titleLower.stringValue', '<=', 'chicken\uf8ff')) \
                          .limit(5)
    docs = query.stream()
    for doc in docs:
        title_data = doc.get('title')
        title = title_data.get('stringValue') if isinstance(title_data, dict) else title_data
        print(f"  - {title}")

if __name__ == "__main__":
    try:
        firestore_client = initialize_firestore()
        validate_data(firestore_client)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
