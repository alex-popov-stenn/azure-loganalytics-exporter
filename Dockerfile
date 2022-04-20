FROM golang:1.18-alpine as build

RUN apk upgrade --no-cache --force
RUN apk add --update build-base make git

WORKDIR /go/src/github.com/webdevops/azure-loganalytics-exporter

# Compile
COPY ./ /go/src/github.com/webdevops/azure-loganalytics-exporter
RUN make dependencies
RUN make test
RUN make build
RUN ./azure-loganalytics-exporter --help

#############################################
# FINAL IMAGE
#############################################
FROM gcr.io/distroless/static
ENV LOG_JSON=1
COPY --from=build /go/src/github.com/webdevops/azure-loganalytics-exporter/azure-loganalytics-exporter /
COPY --from=build /go/src/github.com/webdevops/azure-loganalytics-exporter/templates/ /templates/
USER 1000:1000
EXPOSE 8080
ENTRYPOINT ["/azure-loganalytics-exporter"]
