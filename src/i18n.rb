I18N = {
  ja: {
    question: '問題',
    explanation: '解説',
    initial_view: {
      title: 'ルール',
      description_one: 'これから Ruby に関する 4 択クイズが 5 問出題されます。',
      description_two: 'より多くの問題に正解して、ノベルティを獲得しましょう！',
      start: 'スタート！',
      change_lang: 'Change To English',
    },
    question_result_view: {
      correct: '正解 🎉',
      incorrect: '不正解 😢',
    },
    result_view: {
      title: '結果',
      detail: ->(num) { "5 問中 #{num} 問正解！ 🎉" },
      detail_two: '問正解！',
      blog: 'テックブログにて、このアプリの解説を公開中！',
      blog_alt: 'テックブログページへのQRコード',
      reset: 'リセット',
    }
  },
  en: {
    question: 'Question',
    explanation: 'Explanation',
    initial_view: {
      title: 'Rule',
      description_one: 'You will now be asked five four-choice quizzes about Ruby.',
      description_two: 'Answer more questions correctly to win novelties!',
      start: 'Start!',
      change_lang: '日本語に変える',
    },
    question_result_view: {
      correct: 'Correct 🎉',
      incorrect: 'Incorrect 😢',
    },
    result_view: {
      title: 'Result',
      detail: ->(num) { "#{num} of 5 questions answered correctly! 🎉" },
      blog: 'A description of this application is available on the Tech Blog.',
      blog_alt: 'QR Code to Tech Blog Page',
      reset: 'Reset',
    }
  }
}
