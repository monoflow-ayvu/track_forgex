use rustler::{Encoder, Env, Term, Resource, ResourceArc};
use rustler::NifStruct;
use trackforge::trackers::byte_track::ByteTrack;

rustler::atoms! { error, ok, }

struct ByteTrackInstance(ByteTrack);

impl Resource for ByteTrackInstance {}
impl Encoder for ByteTrackInstance {
  fn encode<'b>(&self, env: Env<'b>) -> Term<'b> {
    (ok(), self).encode(env)
  }
}

#[derive(Debug, NifStruct)]
#[module = "TrackForgex.Trackers.ByteTrackSettings"]
struct ByteTrackSettings {
  /// Threshold for high confidence detections (e.g., 0.5 or 0.6).
  track_thresh: f32,
  /// Number of frames to keep a lost track alive (e.g., 30).
  track_buffer: usize,
  /// IoU threshold for matching (e.g., 0.8).
  match_thresh: f32,
  /// Threshold for initializing a new track (usually same as or slightly lower than track_thresh).
  det_thresh: f32,
}

#[rustler::nif]
fn create_byte_track(settings: ByteTrackSettings) -> ByteTrackInstance {
  let byte_track: ByteTrackInstance = ByteTrackInstance(ByteTrack::new(settings.track_thresh, settings.track_buffer, settings.match_thresh, settings.det_thresh));
  byte_track
}

fn load(env: Env, _term: Term) -> bool {
  env.register::<ByteTrackInstance>().unwrap();
  true
}

rustler::init!("Elixir.TrackForgex.Native", load = load);
