FROM rust:1.75.0-slim-buster as builder

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
# RUN yes | apt install gcc-x86-64-linux-gnu
RUN update-ca-certificates

ENV USER=app
ENV UID=10001
# ENV RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc'

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

WORKDIR /app

COPY ./ .

RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:latest

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /app

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/app ./

USER app:app

CMD ["/app/app"]
