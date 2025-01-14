require "rails_helper"

describe "Poll Votation Type" do
  context "Unique" do
    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:unique) { create(:poll_question_unique, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: unique, title: "answer_1") }
    let!(:answer2) { create(:poll_question_answer, question: unique, title: "answer_2") }

    before do
      login_as(user)
    end

    scenario "response question without votation type" do
      question = create(:poll_question, :yes_no, poll: poll_current)
      visit poll_path(poll_current)

      expect(page).to have_content(question.title)
      expect(page).to have_content(answer1.title)
    end

    scenario "response question with votation type" do
      visit poll_path(poll_current)

      expect(page).to have_content(unique.title)
      expect(page).to have_content(answer1.title)
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      within("#poll_question_#{unique.id}_answers") do
        click_link answer1.title

        expect(page).to have_link answer2.title
        expect(page).not_to have_link answer1.title
      end
    end

    scenario "response question change vote", :js do
      visit poll_path(poll_current)

      within("#poll_question_#{unique.id}_answers") do
        click_link answer1.title

        expect(page).to have_link answer2.title
        expect(page).not_to have_link answer1.title

        click_link answer2.title

        expect(page).to have_link answer1.title
        expect(page).not_to have_link answer2.title
      end
    end
  end

  context "Multiple" do
    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_multiple, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: question, title: "answer_1") }

    before do
      create(:poll_question_answer, question: question, title: "answer_2")
      create(:poll_question_answer, question: question, title: "answer_3")
      create(:poll_question_answer, question: question, title: "answer_4")
      create(:poll_question_answer, question: question, title: "answer_5")

      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title

          expect(page).to have_link answer.title, class: "answered"
        end
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title

          expect(page).to have_link text: answer.title, class: "answered"
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title

        expect(page).not_to have_link text: answer6.title, class: "answered"
      end
    end

    scenario "response question remove vote and vote again", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer1.title

        expect(page).not_to have_link text: answer1.title, class: "answered"
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_link answer6.title

        click_link answer6.title

        expect(page).to have_link answer6.title, class: "answered"
      end
    end
  end

  context "Prioritized" do
    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_prioritized, poll: poll_current) }

    before do
      create(:poll_question_answer, question: question, title: "answer_1")
      create(:poll_question_answer, question: question, title: "answer_2")
      create(:poll_question_answer, question: question, title: "answer_3")
      create(:poll_question_answer, question: question, title: "answer_4")
      create(:poll_question_answer, question: question, title: "answer_5")

      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_link answer.title
        end
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title

          expect(page).to have_link text: answer.title, class: "answered"
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title

        expect(page).not_to have_link answer6.title, class: "answered"
      end
    end
  end

  context "Positive open" do
    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_positive_open, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: question, title: "answer_1") }

    before do
      create(:poll_question_answer, question: question, title: "answer_2")
      create(:poll_question_answer, question: question, title: "answer_3")
      create(:poll_question_answer, question: question, title: "answer_4")
      create(:poll_question_answer, question: question, title: "answer_5")

      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title

          expect(page).to have_link answer.title, class: "answered"
        end
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title

          expect(page).to have_link text: answer.title, class: "answered"
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title

        expect(page).not_to have_link answer6.title, class: "answered"
      end
    end

    scenario "response question remove vote and vote again", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title

          expect(page).to have_link text: answer.title, class: "answered"
        end
      end

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer1.title

        expect(page).not_to have_link text: answer1.title, class: "answered"
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title

        expect(page).to have_link answer6.title, class: "answered"
      end
    end

    scenario "add answer", :js do
      visit poll_path(poll_current)

      fill_in "answer", with: "Added answer"
      click_button "Add answer"

      expect(page).to have_link "Added answer"

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link "Added answer"

        expect(page).to have_link "Added answer", class: "answered"
      end
    end

    scenario "existing given order is bigger than the number of answers", :js do
      answer1.update!(given_order: question.question_answers.count + 1)

      visit poll_path(poll_current)

      fill_in "answer", with: "Added answer"
      click_button "Add answer"

      expect(page).to have_link "Added answer"
    end
  end

  context "Answers set" do
    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_answer_set_open, poll: poll_current) }

    before do
      create(:poll_question_answer, question: question, title: "answer_1")
      create(:poll_question_answer, question: question, title: "answer_2")
      create(:poll_question_answer, question: question, title: "answer_3")
      create(:poll_question_answer, question: question, title: "answer_4")
      create(:poll_question_answer, question: question, title: "answer_5")

      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      expect(page.find("#poll_question_#{question.id}_answers")).to have_css("a", count: question.max_groups_answers)
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.votation_type.votation_set_answers.by_author(user).each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.answer
        end
      end

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_css(".answered", count: question.max_votes)
      end
    end

    scenario "add answer", :js do
      visit poll_path(poll_current)

      fill_in "answer", with: "added_answer"
      click_button "Add answer"

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_content("Answer added succesfully")
      end
    end
  end
end
