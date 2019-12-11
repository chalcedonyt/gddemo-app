# Dockerfile extending the generic Node image with application files for a
# single application.
FROM gcr.io/google_appengine/nodejs
ARG COMMIT=local
# Check to see if the the version included in the base runtime satisfies
# '>=10.14', if not then do an npm install of the latest available
# version that satisfies it.
RUN /usr/local/bin/install_node '>=10.14'
COPY . /app/
# You have to specify "--unsafe-perm" with npm install
# when running as root.  Failing to do this can cause
# install to appear to succeed even if a preinstall
# script fails, and may have other adverse consequences
# as well.

# Build with dev to dist folder and delete after.
ENV NODE_ENV production
# This command will also cat the npm-debug.log file after the
# build, if it exists.
RUN npm install --unsafe-perm || \
  ((if [ -f npm-debug.log ]; then \
      cat npm-debug.log; \
    fi) && false)
ENV NODE_PORT 8080
EXPOSE 8080
RUN mkdir -p public && echo "${COMMIT}" > public/VERSION.txt
RUN echo "Wrote VERSION.txt -> ${COMMIT}"
CMD npm start
