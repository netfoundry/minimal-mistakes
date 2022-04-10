FROM jekyll/jekyll:pages

VOLUME /site

EXPOSE 4000

WORKDIR /site

RUN echo 'gem: --no-document' > /etc/gemrc
RUN gem install jekyll-watch && \
    gem install jekyll-admin && \
    gem install jekyll-paginate && \
    gem install jekyll-sitemap && \
    gem install jekyll-gist && \
    gem install jekyll-feed && \
    gem install jemoji && \
    gem install jekyll-include-cache && \
    gem install jekyll-algolia && \
    gem install tzinfo && \
    gem install json && \
    gem install bigdecimal
#RUN gem install bundler


# TODO seal before ship to optimize storage
#RUN apk del gcc g++ binutils bison perl nodejs make curl && \
#    rm -rf /var/cache/apk/*

CMD ["(set -x; bundle update && bundle install && bundle exec jekyll serve -d /_site --watch --drafts --force_polling -H 0.0.0.0 -P 4000;)"]
ENTRYPOINT ["sh", "-c"]
