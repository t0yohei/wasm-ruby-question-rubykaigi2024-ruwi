# frozen_string_literal: true

require "js"

class Main
  def initialize
    @state = {
      questions: [],
      questionIndex: 0,
      correctAnswerCount: 0,
      lastQuestionResult: '',
      lang: 'ja',
      text: I18N[:ja],
    }
  end

  attr_reader :state

  def showInitialView
    # 初期表示 View
    initialView = ->(state, actions) {
      eval RubyWasmVdom::DomParser.parse(<<-DOM)
        <div>
          <h2>{state[:text][:initial_view][:title]}</h2>
          <button class="changeLangButton button" onclick='{->(e) { actions[:changeLang].call(0, 0) } }'>{state[:text][:initial_view][:change_lang]}</button>
          <ul class="ruleDescription">
            <li>{state[:text][:initial_view][:description_one]}</li>
            <li>{state[:text][:initial_view][:description_two]}</li>
          </ul>

          <img class="officialOgp" src="official_ogp.png" alt="official ogp image" >

          <div class="startResetButtonArea">
            <button class="startResetButton button" onclick='{->(e) { actions[:start].call(0, 0) } }'>{state[:text][:initial_view][:start]}</button>
          </div>
        </div>
      DOM
    }

    actions = {
      # actions 内で引数の数を 2 つにしないとバグるので無理やり2つ設定する
      start: ->(_a, _b) {
        if state[:lang] == 'ja'
          QUESTION_GROUPS.each do |group|
            group_questions = QUESTIONS.select {|question| question[:question_group_id] == group[:id] }
            state[:questions] << group_questions.sample
          end
        else
          QUESTION_GROUPS.each do |group|
            group_questions = ENGLISH_QUESTIONS.select {|question| question[:question_group_id] == group[:id] }
            state[:questions] << group_questions.sample
          end
        end
        puts state[:questions].map{ |q| q[:description] }
        showQuestionView()
      },
      changeLang: ->(_a, _b) {
        if state[:lang] == 'ja'
          state[:lang] = 'en'
          state[:text] = I18N[:en]
        else
          state[:lang] = 'ja'
          state[:text] = I18N[:ja]
        end
        showInitialView()
      }
    }

    renderApp(state: state, view: initialView, actions: actions)
  end

  private

  def renderApp(state:, view:, actions:)
    appEl = JS.global[:document].getElementById('app');
    children = appEl[:children]

    # 既存の view があれば非表示にする。
    if children[:length].to_i > 0
      children[0].remove()
    end

    render = lambda {
      RubyWasmVdom::App.new(
        el: "#app",
        state:,
        view:,
        actions:
      )
    }

    # すぐに描画するとエラーになるので、少し待ってから描画する
    JS.global.call(:setTimeout, JS.try_convert(render))
  end

  def showQuestionView
    # 問題 View
    questionView = ->(state, actions) {
      eval RubyWasmVdom::DomParser.parse(<<-DOM)
        <div>
          <h2>{"#{state[:text][:question]} #{state[:questions].index(state[:questions][state[:questionIndex]]) + 1}: #{state[:questions][state[:questionIndex]][:description]}"}</h2>

          <div class="timer" id="timer">30</div>

          <div class="questionButtons">
            <button class="questionButton button" onclick='{->(e) { actions[:selectChoice].call(state[:questions][state[:questionIndex]], 0) } }'>{state[:questions][state[:questionIndex]][:choices][0]}</button>
            <button class="questionButton button" onclick='{->(e) { actions[:selectChoice].call(state[:questions][state[:questionIndex]], 1) } }'>{state[:questions][state[:questionIndex]][:choices][1]}</button>
            <button class="questionButton button" onclick='{->(e) { actions[:selectChoice].call(state[:questions][state[:questionIndex]], 2) } }'>{state[:questions][state[:questionIndex]][:choices][2]}</button>
            <button class="questionButton button" onclick='{->(e) { actions[:selectChoice].call(state[:questions][state[:questionIndex]], 3) } }'>{state[:questions][state[:questionIndex]][:choices][3]}</button>
          </div>
        </div>
      DOM
    }

    actions = {
      selectChoice: ->(question, choiceIndex) {
        state[:questionIndex] += 1

        if question[:answerIndex] == choiceIndex
          state[:correctAnswerCount] += 1
          state[:lastQuestionResult] = 'correct'
          showQuestionResultView
        else
          state[:lastQuestionResult] = 'incorrect'
          showQuestionResultView
        end

        # タイマーのリセット
        timerEl = JS.global[:document].getElementById('timer')
        timerEl[:textContent] = 30
      },
    }

    renderApp(state: state, view: questionView, actions: actions)
  end

  def showQuestionResultView
    # 回答結果画面用の View
    questionResultView = ->(state, actions) {
      eval RubyWasmVdom::DomParser.parse(<<-DOM)
        <div class="questionResult #{state[:lastQuestionResult]}">
          {state[:text][:question_result_view][state[:lastQuestionResult].to_sym]}
        </div>
      DOM
    }

    renderApp(state: state, view: questionResultView, actions: {})

    renderNextView = lambda {
      if state[:questionIndex] == 5
        showResultView()
      else
        showQuestionView()
      end
    }

    # 次の問題画面 or 結果画面を 1 秒後に表示する
    JS.global.call(:setTimeout, JS.try_convert(renderNextView), 1000)
  end

  def showResultView
    # 結果画面用の View
    resultView = ->(state, actions) {
      eval RubyWasmVdom::DomParser.parse(<<-DOM)
        <div>
          <h2>{state[:text][:result_view][:title]}</h2>
          <div class="resultArea">
            <p class="resultText">{state[:text][:result_view][:detail].call(state[:correctAnswerCount])}</p>
            <div class="techBlogLink">
              <img src="qrcode.png" alt="{state[:text][:result_view][:blog_alt]}" width="100" height="100">
              <span class="blogText">{state[:text][:result_view][:blog]}</span>
            </div>
          </div>

          <h2>{state[:text][:explanation]}</h2>

          <div class="explanationArea">
            <p>{"#{state[:text][:question]} 1: #{state[:questions][0][:description]}"}</p>
            <p>{"#{state[:text][:explanation]}: #{state[:questions][0][:explanation]}"}</p>
            <br/>
            <p>{"#{state[:text][:question]} 2: #{state[:questions][1][:description]}"}</p>
            <p>{"#{state[:text][:explanation]}: #{state[:questions][1][:explanation]}"}</p>
            <br/>
            <p>{"#{state[:text][:question]} 3: #{state[:questions][2][:description]}"}</p>
            <p>{"#{state[:text][:explanation]}: #{state[:questions][2][:explanation]}"}</p>
            <br/>
            <p>{"#{state[:text][:question]} 4: #{state[:questions][3][:description]}"}</p>
            <p>{"#{state[:text][:explanation]}: #{state[:questions][3][:explanation]}"}</p>
            <br/>
            <p>{"#{state[:text][:question]} 5: #{state[:questions][4][:description]}"}</p>
            <p>{"#{state[:text][:explanation]}: #{state[:questions][4][:explanation]}"}</p>
            </div>

          <div class="startResetButtonArea">
            <button class="startResetButton button" onclick='{->(e) { actions[:reset].call(0, 0) } }'>{state[:text][:result_view][:reset]}</button>
          </div>
        </div>
      DOM
    }

    actions = {
      # actions 内で引数の数を 2 つにしないとバグるので無理やり2つ設定する
      reset: ->(_a, _b) {
        JS.global[:window][:location].reload();
      }
    }

    renderApp(state: state, view: resultView, actions: actions)
  end
end

main = Main.new
main.showInitialView()
