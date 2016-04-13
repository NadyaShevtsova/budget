class TransactionsMailer < ApplicationMailer

  def export_transactions data, filename, user
    attachments[filename] = { content: data, mime_type: 'text/csv' }
    mail to: user.email, subject: 'List of transactions'
  end
end
