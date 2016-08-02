"""
Determine the output type of the tuple-to-scalar function assuming that the
tuple-to-scalar function employs the default lifting semantics.
"""
@noinline function determine_output_type(f, cols)
    # Determine the tuple type of the iterator after unwrapping all Nullables.
    unwrapped_types = map(x -> eltype(eltype(x)), cols)

    # See if inference knows the return type for the tuple-to-scalar function.
    T = Core.Inference.return_type(f, (Tuple{unwrapped_types...}, ))

    # When there is no method found, type inference returns Union{}.
    if T == Union{}
        error(
            @sprintf(
                "No method found for the type-signature: %s",
                unwrapped_types,
            )
        )
    end

    return T
end
