#[macro_use] extern crate rustler;
// #[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;
extern crate nalgebra as na;
extern crate ncollide2d;
extern crate nphysics2d;

use na::{Isometry2, Point2, Vector2};
use ncollide2d::shape::{Cuboid, ShapeHandle};
use nphysics2d::object::{BodyHandle, Material};
use nphysics2d::volumetric::Volumetric;
use rustler::{Env, Term, NifResult, Encoder};
use rustler::resource::ResourceArc;
use nphysics2d::world::World;
use std::sync::RwLock;
use std::collections::HashMap;

const COLLIDER_MARGIN: f64 = 0.01;

struct State {
    world: World<f64>,
    body_handles: HashMap<usize, BodyHandle>,
    next_id: usize,
}
struct LockedState {
    state: RwLock<State>,
}

mod atoms {
    rustler_atoms! {
        atom ok;
        //atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

rustler_export_nifs! {
    "Elixir.Physics.Native",
    [
        ("state_new", 0, state_new),
        ("state_step", 1, state_step),
        ("state_get_pos", 2, state_get_pos),
        ("state_add_body", 3, state_add_body),
    ],
    Some(on_init)
}

fn on_init<'a>(env: Env<'a>, _load_info: Term<'a>) -> bool {
    // This macro will take care of defining and initializing a new resource
    // object type.
    // resource_struct_init!(State, env);
    resource_struct_init!(LockedState, env);
    true
}

fn state_new<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    // Create the world state and initialize it with zeroes.
    let mut world = World::new();
    world.set_gravity(Vector2::new(0.0, -9.81));

    let state = State {
        world: world,
        body_handles: HashMap::new(),
        next_id: 0,
    };
    let locked_state = LockedState {
        state: RwLock::new(state),
    };

    Ok(ResourceArc::new(locked_state).encode(env))
}

fn state_step<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let state: ResourceArc<LockedState> = args[0].decode()?;
    let mut state = state.state.write().map_err(|_| {
        rustler::error::Error::RaiseAtom("write_lock")
    })?;

    state.world.step();

    Ok(atoms::ok().encode(env))
}

fn state_get_pos<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let state: ResourceArc<LockedState> = args[0].decode()?;
    let state = state.state.read().map_err(|_| {
        rustler::error::Error::RaiseAtom("read_lock")
    })?;
    let body_id: usize = args[1].decode()?;

    let handle = state.body_handles.get(&body_id).ok_or(rustler::error::Error::RaiseAtom("id_not_found"))?;

    let body = state.world.rigid_body(*handle).ok_or(rustler::error::Error::RaiseAtom("body_not_found"))?;
    let pos = body.position();
    let x = pos.translation.vector.x;
    let y = pos.translation.vector.y;
    let r = pos.rotation.angle();

    Ok((x, y, r).encode(env))
}

fn state_add_body<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let state: ResourceArc<LockedState> = args[0].decode()?;
    let mut state = state.state.write().map_err(|_| {
        rustler::error::Error::RaiseAtom("write_lock")
    })?;
    let x: f64 = args[1].decode()?;
    let y: f64 = args[2].decode()?;

    let geom = ShapeHandle::new(Cuboid::new(Vector2::new(
        1.0,
        1.0,
    )));
    let inertia = geom.inertia(1.0);
    let center_of_mass = geom.center_of_mass();

    let pos = Isometry2::new(Vector2::new(x, y), 0.0);
    let handle = state.world.add_rigid_body(pos, inertia, center_of_mass);
    let id = state.next_id;
    state.next_id += 1;

    state.world.add_collider(
        COLLIDER_MARGIN,
        geom.clone(),
        handle,
        Isometry2::identity(),
        Material::default(),
    );
    state.body_handles.insert(id, handle);

    Ok(id.encode(env))
}
