I18N = {
  ja: {
    question: '問題',
    explanation: '解説',
    correct: '正解',
    incorrect: '不正解',
    initial_view: {
      title: 'ルール',
      description_one: 'これから問題が 5 問出題されます。',
      description_two: '1 つの問題には 4 つの選択肢があり、正解は 1 つです。',
      description_three: '回答を選択すると、正解・不正解が表示されて次の問題に移ります。',
      description_four: '5 問解答が終わると結果画面が表示されて、正答数と各問題の解説が表示されます。',
      description_five: 'より多くの問題に正解して、ノベルティを獲得しましょう！',
      start: 'スタート！',
      change_lang: 'Change To English',
    },
    question_view: {
      title: 'ルール',
      description_one: 'これから問題が 5 問出題されます。',
      description_two: '1 つの問題には 4 つの選択肢があり、正解は 1 つです。',
      description_three: '回答を選択すると、正解・不正解が表示されて次の問題に移ります。',
      description_four: '5 問解答が終わると結果画面が表示されて、正答数と各問題の解説が表示されます。',
      description_five: 'より多くの問題に正解して、ノベルティを獲得しましょう！',
      start: 'スタート！',
      change_lang: 'Change To English',
    },
    result_view: {
      title: '結果',
      detail: ->(num) { "5 問中 #{num} 問正解！" },
      detail_two: '問正解！',
      blog: 'テックブログにて、このアプリの解説を公開中！',
      blog_alt: 'テックブログページへのQRコード',
      reset: 'リセット',
    }
  },
  en: {
    question: 'Question',
    explanation: 'Explanation',
    correct: 'Correct',
    incorrect: 'Incorrect',
    initial_view: {
      title: 'Rule',
      description_one: 'There will now be 5 questions.',
      description_two: 'Each question has four choices, with one correct answer.',
      description_three: 'Once you select an answer, the correct or incorrect answer is displayed and you move on to the next question.',
      description_four: 'After 5 questions are answered, the results screen will appear, showing the number of correct answers and an explanation for each question.',
      description_five: 'Answer more questions correctly to win novelties!',
      start: 'Start!',
      change_lang: '日本語に変える',
    },
    result_view: {
      title: 'Result',
      detail: ->(num) { "#{num} of 5 questions answered correctly!" },
      blog: 'A description of this application is available on the Tech Blog.',
      blog_alt: 'QR Code to Tech Blog Page',
      reset: 'Reset',
    }
  }
}
