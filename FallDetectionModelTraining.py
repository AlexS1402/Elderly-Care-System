import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
import joblib

# Load the dataset
data = pd.read_csv('C:/Users/alexa/OneDrive - University of Chichester/Computer Science/Third Year/Dissertation - COMS607/Database/Machine Learning/acc_gyr.csv')

# Mapping labels to simpler forms
label_mapping = {
    'fall': 'Fall Detected',
    'rfall': 'Fall Detected',
    'lfall': 'Fall Detected',
    'light': 'Light Fall',
    'sit': 'No Fall Detected',
    'walk': 'No Fall Detected',
    'step': 'No Fall Detected'
}
data['label'] = data['label'].map(label_mapping)

# Remove rows with NaN labels if any remain
data = data.dropna(subset=['label'])

# Prepare features and labels
X = data.drop('label', axis=1)
y = data['label']

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Define the parameter grid
param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [None, 10, 20],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4]
}

# Initialize the GridSearchCV object
grid_search = GridSearchCV(estimator=RandomForestClassifier(random_state=42),
                           param_grid=param_grid,
                           cv=3,  # Number of cross-validation folds (k)
                           verbose=2,  # Controls the verbosity: the higher, the more messages
                           n_jobs=-1)  # Number of CPU cores used when parallelizing over classes

# Fit GridSearchCV
grid_search.fit(X_train, y_train)

# Best model after grid search
best_model = grid_search.best_estimator_

# Print best parameters and the score achieved with them
print("Best parameters found: ", grid_search.best_params_)
print("Best cross-validation score: {:.2f}".format(grid_search.best_score_))

# Evaluate on the test set
predictions = best_model.predict(X_test)
print("Classification Report:")
print(classification_report(y_test, predictions))
print("Confusion Matrix:")
print(confusion_matrix(y_test, predictions))

# Save the best model
joblib.dump(best_model, 'ecs_rf_model.pkl')
