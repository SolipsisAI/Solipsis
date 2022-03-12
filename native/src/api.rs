use cortex::core::Cortex;

pub fn chat(models_path: String, text: String) -> String {
    let mut cortex_core = Cortex::new(models_path);
    cortex_core.chat(text)
}
