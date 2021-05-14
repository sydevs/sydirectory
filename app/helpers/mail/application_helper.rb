module Mail::ApplicationHelper

  STATUS_ICONS = {
    created: 'created',
    needs_review: 'alert',
    needs_urgent_review: 'alert',
    expired: 'expired',
    finished: 'verified',
  }.freeze

  STATUS_COLORS = {
    created: '#21ba45',
    needs_review: '#f2711c',
    needs_urgent_review: '#db2828',
    expired: '#008080',
    finished: '#1e5b82',
  }.freeze

  def email_image_tag(image, **options)
    if defined?(attachments)
      attachments[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
      image_tag attachments[image].url, **options
    else
      image_tag image
    end
  end

  def email_login(url)
    defined?(@template_link) ? @template_link + url : url
  end

  def email_status_icon(status)
    content_tag :div, class: 'alert' do
      content_tag :div, class: 'alert__box', style: "background: #{STATUS_COLORS[status]}" do
        content_tag :div, class: 'alert__icon' do
          inline_svg "mail/#{STATUS_ICONS[status]}.svg"
        end
      end
    end
  end

end
