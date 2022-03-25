use std::path::PathBuf;

use cortex::managers::dialoguer::DialogueManager;

pub fn chat(models_path: String, text: String) -> String {
    let models_dir = PathBuf::from(models_path);
    let mut dialoguer = DialogueManager::new(models_dir.join("dialogpt-medium"));
    dialoguer.send(text)
}
