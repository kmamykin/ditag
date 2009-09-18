class Notifier < ActionMailer::Base
  def feedback(from_user, feedback_text)
    recipients %w(kmamyk@gmail.com mamykina@gmail.com)
    from       'support@moddweb.com'
    subject    "[MAHI] Feedback from #{from_user.login}"
    body       :from_user => from_user, :feedback_text => feedback_text
  end
end
