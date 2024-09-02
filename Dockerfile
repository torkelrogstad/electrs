FROM debian:bookworm-slim AS base

RUN apt update -qy
RUN apt install -qy librocksdb-dev

FROM base as build

RUN apt install -qy git cargo clang cmake

WORKDIR /build

# Deps first, for speed
COPY Cargo.toml Cargo.lock ./

# This is a dummy build to get the dependencies cached.
RUN mkdir src && touch src/lib.rs
RUN cargo build --release

COPY . .

RUN cargo build --frozen --release --bin electrs

FROM base as deploy

COPY --from=build /build/target/release/electrs /bin/electrs

EXPOSE 50001

ENTRYPOINT ["/bin/electrs"]