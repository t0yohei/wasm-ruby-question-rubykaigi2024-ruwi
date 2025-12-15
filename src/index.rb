# frozen_string_literal: true

require_relative "i18n"
require_relative "questions"

# メインアプリケーションコンポーネント
MainAppComponent = RubyWasmUi.define_component(
  state: ->(props) {
    {
      questions: [],
      question_index: 0,
      correct_answer_count: 0,
      last_question_result: '',
      lang: 'ja',
      text: I18N[:ja],
      current_view: 'initial',
      timer: 30,
    }
  },

  methods: {
    start_quiz: -> {
      state = self.state
      questions = []

      if state[:lang] == 'ja'
        QUESTION_GROUPS.each do |group|
          group_questions = QUESTIONS.select {|question| question[:question_group_id] == group[:id] }
          questions << group_questions.sample
        end
      else
        QUESTION_GROUPS.each do |group|
          group_questions = ENGLISH_QUESTIONS.select {|question| question[:question_group_id] == group[:id] }
          questions << group_questions.sample
        end
      end

      update_state(questions: questions, question_index: 0, correct_answer_count: 0, current_view: 'question')
    },

    change_language: -> {
      state = self.state
      if state[:lang] == 'ja'
        update_state(lang: 'en', text: I18N[:en])
      else
        update_state( lang: 'ja', text: I18N[:ja])
      end
    },

    select_choice: ->(choice_index) {
      state = self.state
      current_question = state[:questions][state[:question_index]]
      new_question_index = state[:question_index] + 1

      if current_question[:answerIndex] == choice_index
        update_state(
          question_index: new_question_index,
          correct_answer_count: state[:correct_answer_count] + 1,
          last_question_result: 'correct',
          current_view: 'question_result'
        )
      else
        update_state(
          question_index: new_question_index,
          last_question_result: 'incorrect',
          current_view: 'question_result'
        )
      end

      # 1秒後に次の画面に遷移
      JS.global.call(:setTimeout, JS.try_convert(-> {
        state = self.state
        if state[:question_index] == 5
          update_state(current_view: 'result', timer: 30)
        else
          update_state(current_view: 'question', timer: 30)
        end
      }), 1000)
    },

    update_timer: ->(timer) {
      update_state(timer: timer)
    },

    reset_quiz: -> {
      JS.global[:window][:location].reload()
    }
  },

  template: ->(component) {
    state = component.state

    RubyWasmUi::Template::Parser.parse_and_eval(<<~HTML, binding)
      <div>
        <initial-view-component
          r-if="{state[:current_view] == 'initial'}"
          lang="{state[:lang]}"
          text="{state[:text]}"
          on="{
            start: -> { component.start_quiz },
            change_lang: -> { component.change_language }
          }">
        </initial-view-component>

        <question-view-component
          r-if="{state[:current_view] == 'question'}"
          questions="{state[:questions]}"
          question_index="{state[:question_index]}"
          text="{state[:text]}"
          timer="{state[:timer]}"
          on="{
            select_choice: ->(choice_index) { component.select_choice(choice_index) },
            update_timer: ->(timer) { component.update_timer(timer) }
          }">
        </question-view-component>

        <question-result-view-component
          r-if="{state[:current_view] == 'question_result'}"
          last_question_result="{state[:last_question_result]}"
          text="{state[:text]}">
        </question-result-view-component>

        <result-view-component
          r-if="{state[:current_view] == 'result'}"
          correct_answer_count="{state[:correct_answer_count]}"
          questions="{state[:questions]}"
          text="{state[:text]}"
          on="{
            reset: -> { component.reset_quiz }
          }">
        </result-view-component>
      </div>
    HTML
  }
)

# 初期表示コンポーネント
InitialViewComponent = RubyWasmUi.define_component(
  template: ->(component) {
    props = component.props
    RubyWasmUi::Template::Parser.parse_and_eval(<<~HTML, binding)
      <div>
        <h2>{props[:text][:initial_view][:title]}</h2>
        <button class="changeLangButton button" on="{click: ->(e) { component.emit('change_lang', e) }}">
          {props[:text][:initial_view][:change_lang]}
        </button>
        <ul class="ruleDescription">
          <li>{props[:text][:initial_view][:description_one]}</li>
          <li>{props[:text][:initial_view][:description_two]}</li>
        </ul>

        <img class="officialOgp" src="official_ogp.png" alt="official ogp image" />

        <div class="startResetButtonArea">
          <button class="startResetButton button" on="{click: ->(e) { component.emit('start', e) }}">
            {props[:text][:initial_view][:start]}
          </button>
        </div>
      </div>
    HTML
  }
)

# 問題表示コンポーネント
QuestionViewComponent = RubyWasmUi.define_component(
  template: ->(component) {
    props = component.props
    questions = props[:questions] || []
    question_index = props[:question_index] || 0
    text = props[:text] || I18N[:ja]
    current_question = questions[question_index]
    question_number = question_index + 1
    timer = props[:timer] || 30

    RubyWasmUi::Template::Parser.parse_and_eval(<<~HTML, binding)
      <div>
        <h2>
          {text[:question]} {question_number}: {current_question[:description]}
        </h2>

        <timer-component timer="{timer}" on="{update_timer: ->(timer) { component.emit('update_timer', timer) }}"></timer-component>

        <div class="questionButtons">
          <button class="questionButton button" on="{click: ->(e) { component.emit('select_choice', 0) }}">
            {current_question[:choices][0]}
          </button>
          <button class="questionButton button" on="{click: ->(e) { component.emit('select_choice', 1) }}">
            {current_question[:choices][1]}
          </button>
          <button class="questionButton button" on="{click: ->(e) { component.emit('select_choice', 2) }}">
            {current_question[:choices][2]}
          </button>
          <button class="questionButton button" on="{click: ->(e) { component.emit('select_choice', 3) }}">
            {current_question[:choices][3]}
          </button>
        </div>
      </div>
    HTML
  }
)

# タイマー表示コンポーネント
TimerComponent = RubyWasmUi.define_component(
  template: ->(component) {
    props = component.props
    timer = props[:timer] || 30
    RubyWasmUi::Template::Parser.parse_and_eval(<<~HTML, binding)
      <div class="timer" id="timer">{timer}</div>
    HTML
  },

  on_mounted: ->(component) {
    JS.global.call(:setInterval, JS.try_convert(-> {
      component.emit('update_timer', component.props[:timer] - 1)
    }), 1000)
  }
)

# 問題結果表示コンポーネント
QuestionResultViewComponent = RubyWasmUi.define_component(
  template: ->(component) {
    props = component.props
    last_question_result = props[:last_question_result] || ''
    text = props[:text] || I18N[:ja]
    result_class = last_question_result
    result_text = text[:question_result_view][last_question_result.to_sym]
    RubyWasmUi::Template::Parser.parse_and_eval(<<~HTML, binding)
      <div class="questionResult #{result_class}">
        {result_text}
      </div>
    HTML
  }
)

# 最終結果表示コンポーネント
ResultViewComponent = RubyWasmUi.define_component(
  template: ->(component) {
    props = component.props
    correct_answer_count = props[:correct_answer_count] || 0
    text = props[:text] || I18N[:ja]
    result_detail = text[:result_view][:detail].call(correct_answer_count)
    RubyWasmUi::Template::Parser.parse_and_eval(<<~HTML, binding)
      <div>
        <h2>{text[:result_view][:title]}</h2>
        <div class="resultArea">
          <p class="resultText">{result_detail}</p>
          <div class="techBlogLink">
            <img src="qrcode.png" alt="{text[:result_view][:blog_alt]}" width="100" height="100" />
            <span class="blogText">{text[:result_view][:blog]}</span>
          </div>
        </div>

        <h2>{text[:explanation]}</h2>

        <div class="explanationArea">
          <p>{text[:question]} 1: {props[:questions][0][:description]}</p>
          <p>{text[:explanation]}: {props[:questions][0][:explanation]}</p>
          <br/>
          <p>{text[:question]} 2: {props[:questions][1][:description]}</p>
          <p>{text[:explanation]}: {props[:questions][1][:explanation]}</p>
          <br/>
          <p>{text[:question]} 3: {props[:questions][2][:description]}</p>
          <p>{text[:explanation]}: {props[:questions][2][:explanation]}</p>
          <br/>
          <p>{text[:question]} 4: {props[:questions][3][:description]}</p>
          <p>{text[:explanation]}: {props[:questions][3][:explanation]}</p>
          <br/>
          <p>{text[:question]} 5: {props[:questions][4][:description]}</p>
          <p>{text[:explanation]}: {props[:questions][4][:explanation]}</p>
        </div>

        <div class="startResetButtonArea">
          <button class="startResetButton button" on="{click: ->(e) { component.emit('reset', e) }}">
            {text[:result_view][:reset]}
          </button>
        </div>
      </div>
    HTML
  }
)

# アプリケーションの作成とマウント
app = RubyWasmUi::App.create(MainAppComponent)
app_element = JS.global[:document].getElementById("app")
app.mount(app_element)
