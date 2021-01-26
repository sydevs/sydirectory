module Expirable

  extend ActiveSupport::Concern

  TEST_MODE = true

  BASE_DURATION = TEST_MODE ? 10 : 8
  DURATION_INCREMENT = TEST_MODE ? 10 : 1

  LEVELS = {
    verify: 0,
    escalate: 1,
    expire: 2,
    archive: 3
  }.freeze

  included do
    scope :not_expired, -> { where("#{table_name}.updated_at > ?", Expirable.date_for(:expire)) }
    scope :needs_review, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", Expirable.date_for(:verify), Expirable.date_for(:archive)) }
    scope :needs_urgent_review, -> { where("#{table_name}.updated_at < ? AND #{table_name}.updated_at > ?", Expirable.date_for(:escalate), Expirable.date_for(:verify)) }
    scope :expired, -> { where("#{table_name}.updated_at <= ?", Expirable.date_for(:expire)) }
    scope :recently_expired, -> { where("#{table_name}.updated_at <= ? AND #{table_name}.updated_at > ?", Expirable.date_for(:expire), Expirable.date_for(:archive)) }
    scope :archived, -> { where("#{table_name}.updated_at <= ?", Expirable.date_for(:archive)) }
    scope :no_recent_email_sent, -> (field) { where("#{field} IS NULL OR #{field} > ?", Expirable.date_for(:interval)) }
  end

  def self.duration_for(level)
    if level == :interval
      base = DURATION_INCREMENT
    else
      base = BASE_DURATION + (LEVELS[level] * DURATION_INCREMENT)
    end
    
    TEST_MODE ? base.minutes : base.weeks
  end

  def self.date_for(level)
    Expirable.duration_for(level).ago
  end

  def needs_review_at
    updated_at + Expirable.duration_for(:verify)
  end

  def needs_escalation_at
    updated_at + Expirable.duration_for(:escalate)
  end

  def expires_at
    updated_at + Expirable.duration_for(:expire)
  end

  def archives_at
    updated_at + Expirable.duration_for(:archive)
  end

  def expired_at
    expires_at
  end

  def active?
    Time.now < expires_at
  end

  def updated?
    !expired? && !needs_review?
  end

  def expired?
    !active?
  end

  def archived?
    Time.now >= archives_at
  end

  def needs_review? urgency = :any
    if urgency == :urgent
      updated_at < Expirable.date_for(:verify)
    else
      updated_at < Expirable.date_for(:escalate)
    end
  end

end
