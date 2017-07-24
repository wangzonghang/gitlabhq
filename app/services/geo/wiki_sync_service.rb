module Geo
  class WikiSyncService < BaseSyncService
    self.type = :wiki

    private

    def sync_repository
      fetch_wiki_repository
    end

    def fetch_wiki_repository
      log('Fetching wiki repository')
      update_registry(:wiki, started_at: DateTime.now)

      begin
        project.wiki.ensure_repository
        project.wiki.repository.fetch_geo_mirror(ssh_url_to_wiki)

        update_registry(:wiki, finished_at: DateTime.now)
      rescue Gitlab::Git::Repository::NoRepository,
             Gitlab::Shell::Error,
             ProjectWiki::CouldNotCreateWikiError,
             Geo::EmptyCloneUrlPrefixError => e
        Rails.logger.error("#{self.class.name}: Error syncing wiki repository for project #{project.path_with_namespace}: #{e}")
      end
    end

    def ssh_url_to_wiki
      "#{primary_ssh_path_prefix}#{project.path_with_namespace}.wiki.git"
    end
  end
end
