use rust_bert::pipelines::question_answering::{QaInput, QuestionAnsweringModel};

pub fn ask(question: String, context: String) -> String {
    let qa_model = QuestionAnsweringModel::new(Default::default());
    let answers = qa_model
        .unwrap()
        .predict(&[QaInput { question, context }], 1, 32);
    let answer = &answers[0][0].answer;
    answer.into()
}
