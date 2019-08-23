class ::Webdrivers::Common
  class << self
    private

    # 複数のサーバに同じブラウザのドライバをインストールすることを考慮し、
    # キャッシュファイルを作成しない
    def with_cache(file_name)
      version = yield
      normalize_version version
    end
  end
end