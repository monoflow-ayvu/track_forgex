use rustler::NifStruct;
use rustler::{Env, Resource, ResourceArc, Term};
use trackforge::trackers::byte_track::ByteTrack;

rustler::atoms! { error, ok, }

struct ByteTrackInstance {
    tracker: ByteTrack,
}

impl Resource for ByteTrackInstance {}

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
fn create_byte_track(settings: ByteTrackSettings) -> ResourceArc<ByteTrackInstance> {
    let tracker = ByteTrack::new(
        settings.track_thresh,
        settings.track_buffer,
        settings.match_thresh,
        settings.det_thresh,
    );
    ResourceArc::new(ByteTrackInstance { tracker })
}

fn load(env: Env, _term: Term) -> bool {
    env.register::<ByteTrackInstance>().unwrap();
    true
}

rustler::init!("Elixir.TrackForgex.Native", load = load);
